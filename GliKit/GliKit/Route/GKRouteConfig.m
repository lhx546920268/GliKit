//
//  GKRouteConfig.m
//  GliKit
//
//  Created by 罗海雄 on 2022/6/24.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "GKRouteConfig.h"

///路由属性
@interface GKRouteConfig()

///路由参数
@property(nonatomic, strong) NSDictionary *routeParams;

@end

@implementation GKRouteConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.animated = YES;
    }
    return self;
}

- (BOOL)isPresent
{
    return self.style == GKRouteStylePresent || self.style == GKRouteStylePresentWithoutNavigationBar;
}

- (NSString *)URLString
{
    if(_URLString){
        return _URLString;
    }
    
    return self.URLComponents.string;
}

- (NSString *)path
{
    if(_path){
        return _path;
    }
    
    NSURLComponents *components = self.URLComponents;
    if(!components && self.URLString){
        components = [NSURLComponents componentsWithString:self.URLString];
    }
    
    if(components){
        _path = components.path;
    }
    
    return _path;
}

- (NSDictionary *)mExtras
{
    if(!_extras){
        _extras = [NSMutableDictionary dictionary];
    }
    NSAssert([_extras isKindOfClass:NSMutableDictionary.class], @"CARouteConfig.mExtras must be NSMutableDictionary");
    
    return _extras;
}

- (BOOL)isEqual:(GKRouteConfig*) config
{
    if (![config isKindOfClass:GKRouteConfig.class]) {
        return NO;
    }
    
    if (![config.path isEqualToString:self.path]) {
        return NO;
    }
    
    return [self.routeParams isEqualToDictionary:config.routeParams];
}

@end
