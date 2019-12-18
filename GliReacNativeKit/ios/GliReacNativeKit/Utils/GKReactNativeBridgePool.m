//
//  GKReactNativeBridgePool.m
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/17.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKReactNativeBridgePool.h"
#import <React/RCTBridge.h>
#import "GKReactNativeDefaultLoader.h"
#import <React/RCTAssert.h>

@interface GKReactNativeBridge ()<RCTBridgeDelegate>

@end

@implementation GKReactNativeBridge

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
    self.bridge = bridge;
    return GKReactNativeBridgePool.sharedPool.documentBasicBundleURL;
}

@end

@interface GKReactNativeBridgePool ()

///当前桥接
@property(nonatomic, strong) NSMutableDictionary<NSString*, GKReactNativeBridge*> *bridges;

///预加载的桥接
@property(nonatomic, strong) GKReactNativeBridge *cachedBridge;

@end

@implementation GKReactNativeBridgePool

@synthesize documentBasicBundleURL = _documentBasicBundleURL;

+ (__kindof GKReactNativeBridgePool*)sharedPool
{
    static GKReactNativeBridgePool *sharedPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedPool = self.class.new;
    });
    
    return sharedPool;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        
        RCTSetFatalHandler(^(NSError *error) {
            
        });
        self.bridges = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bridgeDidDownloadScript:) name:RCTBridgeDidDownloadScriptNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSURL *)documentBasicBundleURL
{
    if(!_documentBasicBundleURL){
        _documentBasicBundleURL = [NSURL fileURLWithPath:[[GKReactNativeDefaultLoader reactNativeDirectory] stringByAppendingPathComponent:@"basic.jsbundle"]];
    }
    
    return _documentBasicBundleURL;
}

- (void)initPool
{
    if(![NSFileManager.defaultManager fileExistsAtPath:self.documentBasicBundleURL.path] && self.mainBasicBundleURL){
        [NSFileManager.defaultManager copyItemAtURL:self.mainBasicBundleURL toURL:self.documentBasicBundleURL error:nil];
    }
    [self preLoadBridge];
}

- (void)fetchBridgeWithModuleName:(NSString *)moduleName version:(NSString *)version completion:(GKReactNativeFetchBridgeCompletion)completion
{
    if(![NSFileManager.defaultManager fileExistsAtPath:self.documentBasicBundleURL.path]){
        !completion ?: completion(nil);
        return;
    }
    GKReactNativeBridge *bridge = self.bridges[moduleName];
    
    //如果要更新，把队列里面的桥接删了
    if(bridge && ![bridge.version isEqualToString:version]){
        bridge = nil;
    }
    
    //如果缓存里面有，拿缓存的
    if(!bridge && self.cachedBridge){
        bridge = self.cachedBridge;
        [self preLoadBridge];
    }
    
    if(!bridge){
        bridge = GKReactNativeBridge.new;
    }
    
    bridge.version = version;
    bridge.moduleName = moduleName;
    bridge.completion = completion;
    self.bridges[moduleName] = bridge;
    
    if(bridge.didLoadBasicJs){
        
        !completion ?: completion(bridge);
    }else{
        
        bridge.bridge = [[RCTBridge alloc] initWithDelegate:bridge launchOptions:nil];;
    }
}

///预加载一个
- (void)preLoadBridge
{
    self.cachedBridge = GKReactNativeBridge.new;
    self.cachedBridge.bridge = [[RCTBridge alloc] initWithDelegate:self.cachedBridge launchOptions:nil];;
}

// MARK: - 通知

//js加载完成
- (void)bridgeDidDownloadScript:(NSNotification*) notification
{
    RCTBridge *bridge = notification.object;
    if(bridge == self.cachedBridge.bridge){
        self.cachedBridge.didLoadBasicJs = YES;
        return;
    }
    
    for(NSString *key in self.bridges){
        GKReactNativeBridge *rnBridge = self.bridges[key];
        if(rnBridge.bridge == bridge){
            
            rnBridge.didLoadBasicJs = YES;
            !rnBridge.completion ?: rnBridge.completion(rnBridge);
            rnBridge.completion = nil;
            break;
        }
    }
}

@end
