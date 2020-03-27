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
#import <sys/utsname.h>
#import "NSString+GKUtils.h"
#import <Photos/Photos.h>
#import <SDWebImageDefine.h>
#import "UIApplication+GKTheme.h"

///当前设备唯一标识符
static NSString *sharedUUID = nil;

@implementation GKAppUtils

+ (NSString*)appVersion
{
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isTestApp
{
    return GKAppUtils.appVersion.length > 7;
}

+ (NSString*)appName
{
    NSString *name = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"];
    if([NSString isEmpty:name]){
        name = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    }
    
    return name;
}

+ (UIImage*)appIcon
{
    NSDictionary *dic = NSBundle.mainBundle.infoDictionary;
    NSString *iconName = [[dic objectForKey:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    
    return [UIImage imageNamed:iconName];
}

+ (NSString *)bundleId
{
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"];
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
                
                //兼容以前的 现在改成 ZegoBird 和 ZegoDealer 共享keychain
                uuid = [GKKeyChainStore stringForKey:key service:service];
            }
            
            if([NSString isEmpty:uuid]){
                CFUUIDRef uuidRef = CFUUIDCreate(NULL);
                CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
                CFRelease(uuidRef);
                uuid = [NSString stringWithString:(__bridge NSString*)uuidStringRef];
                CFRelease(uuidStringRef);
            }
            
            [GKKeyChainStore setString:uuid forKey:key service:service accessGroup:UIApplication.gkKeychainAcessGroup];
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:[NSString stringWithFormat:@"%@%@", service, key]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //添加手机型号
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        
        sharedUUID = [NSString stringWithFormat:@"%@_%@", uuid, deviceModel];
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

+ (void)makePhoneCall:(NSString*) mobile shouldAlert:(BOOL) alert
{
    if(![NSString isEmpty:mobile]){
        if(alert){
            [GKAlertUtils showAlertWithMessage:[NSString stringWithFormat:@"Call %@", mobile] handler:^{
                [GKAppUtils openCompatURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", mobile]]];
            }];
        }else{
            [GKAppUtils openCompatURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", mobile]]];
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

+ (void)requestPhotosAuthorizationWithCompletion:(void (^)(BOOL))completion
{
    PHAuthorizationStatus status = PHPhotoLibrary.authorizationStatus;
    if(status == PHAuthorizationStatusNotDetermined){
        //没有权限 先申请授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //可能在其他线程回调
            dispatch_main_async_safe(^{
                !completion ?: completion(status == PHAuthorizationStatusAuthorized);
            })
        }];
    }else{
        !completion ?: completion(status == PHAuthorizationStatusAuthorized);
    }
}

@end
