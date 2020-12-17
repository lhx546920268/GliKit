//
//  GKAppUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/26.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAppUtils.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <dlfcn.h>
#import "GKAlertUtils.h"
#import "GKKeyChainStore.h"
#import "NSString+GKUtils.h"
#import <Photos/Photos.h>
#import <SDWebImageDefine.h>
#import "UIApplication+GKTheme.h"
#import "NSDictionary+GKUtils.h"

///当前设备唯一标识符
static NSString *sharedUUID = nil;

@implementation GKAppUtils

+ (NSString*)appVersion
{
    return [NSBundle.mainBundle.infoDictionary gkStringForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isTestApp
{
    return [GKAppUtils.appVersion componentsSeparatedByString:@"."].count > 3;
}

+ (NSString*)appName
{
    NSString *name = [NSBundle.mainBundle.infoDictionary gkStringForKey:@"CFBundleDisplayName"];
    if([NSString isEmpty:name]){
        name = [NSBundle.mainBundle.infoDictionary gkStringForKey:@"CFBundleName"];
    }
    
    return name;
}

+ (UIImage*)appIcon
{
    NSDictionary *dic = NSBundle.mainBundle.infoDictionary;
    NSString *iconName = [[dic gkArrayForKey:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    if(![NSString isEmpty:iconName]){
        return [UIImage imageNamed:iconName];
    }
    return nil;
}

+ (NSString *)bundleId
{
    return [NSBundle.mainBundle.infoDictionary gkStringForKey:@"CFBundleIdentifier"];
}

+ (NSString*)uuid
{
    if([NSString isEmpty:sharedUUID]){
        NSString *service = self.bundleId;
        NSString *key = @"GliKitUUID";
        
        NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@%@", service, key]];
        if([NSString isEmpty:uuid]){
            uuid = [GKKeyChainStore stringForKey:key service:service accessGroup:UIApplication.gkKeychainAcessGroup];
            
            if([NSString isEmpty:uuid]){
                uuid = NSUUID.new.UUIDString;
                [GKKeyChainStore setString:uuid forKey:key service:service accessGroup:UIApplication.gkKeychainAcessGroup];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:[NSString stringWithFormat:@"%@%@", service, key]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        sharedUUID = uuid;
        if(!sharedUUID){
            sharedUUID = @"";
        }
#ifdef DEBUG
        NSLog(@"UUID = %@", sharedUUID);
#endif
    }
    
    return sharedUUID;
}

+ (NSString *)currentIP
{
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    success = getifaddrs(&addrs) == 0;
    NSString *ip = nil;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0){
                ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return ip;
}

+ (void)makePhoneCall:(NSString*) mobile
{
    if(![NSString isEmpty:mobile]){
        if(@available(iOS 10, *)){
            //iOS 10 后拨打电话 会有系统弹窗
            [GKAppUtils openCompatURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", mobile]]];
        }else{
            [GKAlertUtils showAlertWithMessage:[NSString stringWithFormat:@"是否拨打 %@", mobile] handler:^{
                [GKAppUtils openCompatURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", mobile]]];
            }];
        }
    }
}

+ (void)openCompatURL:(NSURL*) URL
{
    [self openCompatURL:URL callCanOpen:YES];
}

+ (void)openCompatURL:(NSURL *)URL callCanOpen:(BOOL)call
{
    if(call){
        if([UIApplication.sharedApplication canOpenURL:URL]){
            [self openCompatURLDirectly:URL];
        }
    }else{
        [self openCompatURLDirectly:URL];
    }
}

+ (void)openCompatURLDirectly:(NSURL *)URL
{
    if(@available(iOS 10, *)){
        [UIApplication.sharedApplication openURL:URL options:[NSDictionary dictionary] completionHandler:nil];
    }else{
        [UIApplication.sharedApplication openURL:URL];
    }
}

+ (void)openSettings
{
    [GKAppUtils openCompatURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (BOOL)hasPhotosAuthorization
{
    if(@available(iOS 14, *)){
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        if(status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited){
            return YES;
        }
    }else{
        return PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized;
    }
    return NO;
}

///当前相册权限
+ (PHAuthorizationStatus)photosAuthorizationStatus
{
    if(@available(iOS 14, *)){
        return [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }else{
        return PHPhotoLibrary.authorizationStatus;
    }
}

+ (void)requestPhotosAuthorizationWithCompletion:(void (^)(BOOL))completion
{
    if(self.photosAuthorizationStatus == PHAuthorizationStatusNotDetermined){
        //没有权限 先申请授权
        if(@available(iOS 14, *)){
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                //可能在其他线程回调
                dispatch_main_async_safe(^{
                    !completion ?: completion(GKAppUtils.hasPhotosAuthorization);
                })
            }];
        }else{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                //可能在其他线程回调
                dispatch_main_async_safe(^{
                    !completion ?: completion(GKAppUtils.hasPhotosAuthorization);
                })
            }];
        }
    }else{
        !completion ?: completion(GKAppUtils.hasPhotosAuthorization);
    }
}

@end
