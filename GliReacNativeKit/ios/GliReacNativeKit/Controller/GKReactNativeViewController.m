//
//  GKReactNativeViewController.m
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/17.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKReactNativeViewController.h"
#import <React/RCTRootView.h>
#import <GKPageLoadingContainer.h>
#import "GKReactNativeVersionModel.h"
#import <GKAppUtils.h>
#import "GKReactNativeBridgePool.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTBundleURLProvider.h>
#import "GKReactNativeDefaultLoader.h"
#import <UIViewController+GKLoading.h>
#import <GKBaseDefines.h>
#import <UIScreen+GKUtils.h>

@interface RCTBridge (GKReactNativeLoadJS) // RN私有类 ，这里暴露他的接口

- (void)executeSourceCode:(NSData *)sourceCode sync:(BOOL)sync;

@end

@interface GKReactNativeViewController ()

///rn是否已加载完成
@property(nonatomic, assign) BOOL reactNativeDidLoad;

///显示rn的视图
@property(nonatomic, strong) RCTRootView *rnRootView;

@end

@implementation GKReactNativeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gkReloadData];
}

- (void)setReactNativeDidLoad:(BOOL)reactNativeDidLoad
{
    if(_reactNativeDidLoad != reactNativeDidLoad){
        _reactNativeDidLoad = reactNativeDidLoad;
        
        [self setNavigatonBarHidden:_reactNativeDidLoad animate:NO];
        if(_reactNativeDidLoad){
            self.reactNativeLoader = nil;
        }
    }
}

- (id<GKReactNativeLoader>)reactNativeLoader
{
    if(!_reactNativeLoader){
        _reactNativeLoader = [[GKReactNativeDefaultLoader alloc] initWithModuleName:self.moduleName];
    }
    
    return _reactNativeLoader;
}


// MARK: - load RN

- (void)gkReloadData
{
    [super gkReloadData];
    self.gkShowPageLoading = YES;
    [self loadReactNative];
}

//加载rn
- (void)loadReactNative
{
#if RNDebug
    NSURL *bundleURl = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:self.localIndexPath fallbackResource:nil];
    GKReactNativeBridge *bridge = GKReactNativeBridge.new;
    bridge.didLoadBasicJs = YES;
    bridge.didLoadBusinessJs = YES;
    bridge.moduleName = self.moduleName;
    bridge.bridge = [[RCTBridge alloc] initWithBundleURL:bundleURl moduleProvider:nil launchOptions:nil];
    
    [self onLoadBridge:bridge];
#else
    
    WeakObj(self)
    [self.reactNativeLoader loadReactNativeFileWithCompletionHandler:^(NSURL *bundleURL, NSString *moduleName, GKReactNativeVersionModel *model) {
        
        [selfWeak onLoadReactNativeWithBundleURL:bundleURL model:model];
    }];
#endif
}

//加载rn完成
- (void)onLoadReactNativeWithBundleURL:(NSURL*) bundleURL model:(GKReactNativeVersionModel*) model
{
    if(bundleURL){
        
        WeakObj(self)
        [GKReactNativeBridgePool.sharedPool fetchBridgeWithModuleName:self.moduleName version:model.reactNativeVersion completion:^(GKReactNativeBridge * _Nonnull bridge) {
            if(bridge){
                [selfWeak onLoadBridge:bridge];
            }else{
                [selfWeak onReactNativeLoadFailWithModel:model];
            }
        }];
    }else{
        [self onReactNativeLoadFailWithModel:model];
    }
}

- (void)onReactNativeLoadFailWithModel:(GKReactNativeVersionModel *)model
{
    self.gkShowFailPage = YES;
}

//加载桥接完成
- (void)onLoadBridge:(GKReactNativeBridge*) bridge
{
    self.gkShowPageLoading = NO;
    self.reactNativeDidLoad = YES;
    
    if(self.rnRootView){
        [self.rnRootView removeFromSuperview];
    }
    
    GKPageLoadingContainer *loadingView = nil;
    
    //加载业务包
    if(!bridge.didLoadBusinessJs){
        [bridge.bridge.batchedBridge executeSourceCode:[NSData dataWithContentsOfFile:[GKReactNativeDefaultLoader reactNativeBundlePathForModuleName:self.moduleName]] sync:NO];
        bridge.didLoadBusinessJs = YES;
        loadingView = [GKPageLoadingContainer new];
        loadingView.frame = CGRectMake(0, 0, UIScreen.gkScreenWidth, UIScreen.gkScreenHeight);
    }
    
    self.rnRootView = [[RCTRootView alloc] initWithBridge:bridge.bridge moduleName:self.moduleName initialProperties:self.extendProperties];
    self.rnRootView.loadingViewFadeDelay = 0;
    self.rnRootView.loadingViewFadeDuration = 0;
    self.rnRootView.loadingView = loadingView;
    [self.view addSubview:self.rnRootView];
    
    [self.rnRootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self onRactNativeDisplay];
}

- (void)onRactNativeDisplay
{
    
}


@end
