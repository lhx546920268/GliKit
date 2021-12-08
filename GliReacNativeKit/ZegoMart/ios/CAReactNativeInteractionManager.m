//
//  CAReactNativeInteractionManager.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/6/17.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "CAReactNativeInteractionManager.h"
#import <React/RCTConvert.h>

@implementation CAReactNativeInteractionManager

//导出该类 名称为 ReactNativeInteraction 给rn调用
RCT_EXPORT_MODULE(ReactNativeInteraction)

- (instancetype)init
{
    self = [super init];
    if (self) {
        
       
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"EVENT_ON_LOGIN", @"EVENT_ON_LOGOUT", @"EVENT_ON_ADD_SHOPPING_CART", @"EVENT_ON_ORDER_CONFIRM"];
}

+ (NSDictionary *)currentUserInfo
{
    return nil;
}

///获取当前语言
RCT_EXPORT_METHOD(getCurrentLanguage:(RCTResponseSenderBlock) callback)
{
    
}

///获取当前用户信息
RCT_EXPORT_METHOD(getCurrentUserInfo:(RCTResponseSenderBlock) callback)
{
    
}

///登录
RCT_EXPORT_METHOD(login:(RCTResponseSenderBlock) callback)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogin" object:nil];
  });
}

///修改状态栏样式
RCT_EXPORT_METHOD(setStatusBarStyle:(NSString*) style)
{
    
}

///返回上一页
RCT_EXPORT_METHOD(goBack)
{
    
}

///打开新界面
RCT_EXPORT_METHOD(openAppWindow:(NSDictionary*) data)
{
    
}

///显示Toast
RCT_EXPORT_METHOD(showErrorToast:(NSString*) text)
{
    
}

///显示Toast
RCT_EXPORT_METHOD(showSuccessToast:(NSString*) text)
{
    
}

///显示Toast
RCT_EXPORT_METHOD(showWarningToast:(NSString*) text)
{
    
}


///显示Toast
RCT_EXPORT_METHOD(showLoadingToast:(id) params)
{
    
}

///隐藏loading
RCT_EXPORT_METHOD(hideLoadingToast)
{
    
}

///购物车更新了
RCT_EXPORT_METHOD(shopCartUpdate)
{
    
}

///打开广告
RCT_EXPORT_METHOD(openAdvertising:(NSString*) data)
{
    
}

///是否可以滑动返回
RCT_EXPORT_METHOD(setInteractivePopEnable:(NSString*) enable)
{
    
}

// MARK: - 通知

///用户登录
- (void)userDidLogin:(NSNotification*) notification
{
    [self sendEventWithName:@"EVENT_ON_LOGIN" body:CAReactNativeInteractionManager.currentUserInfo];
}

///用户登录
- (void)userDidLogout:(NSNotification*) notification
{
    [self sendEventWithName:@"EVENT_ON_LOGOUT" body:nil];
}

///有商品加入购物车了
- (void)shopCartDidAdd:(NSNotification*) notification
{
    //不是react-native 的更新购物车才刷新
    
}

///订单创建了
- (void)orderDidCreate:(NSNotification*) notification
{
    [self sendEventWithName:@"EVENT_ON_ORDER_CONFIRM" body:nil];
}


@end
