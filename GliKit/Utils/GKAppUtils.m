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
#import "GKSSKeychain.h"
#import <sys/utsname.h>
#import "NSString+GKUtils.h"

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
    NSString *iconName = [[dic valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    
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
        NSString *account = @"lhxUUID";
        
        NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@%@", service, account]];
        if([NSString isEmpty:uuid]){
            uuid = [GKSSKeychain passwordForService:service account:account error:nil];
        }
        
        if([NSString isEmpty:uuid]){
            CFUUIDRef uuidRef = CFUUIDCreate(NULL);
            CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
            CFRelease(uuidRef);
            uuid = [NSString stringWithString:(__bridge NSString*)uuidStringRef];
            CFRelease(uuidStringRef);
            
            [GKSSKeychain setPassword:uuid forService:service account:account error:nil];
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:[NSString stringWithFormat:@"%@%@", service, account]];
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
        NSLog(@"UUID = %@", sharedUUID);
    }
    
    return sharedUUID;
}

+ (NSString *)currentIP
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0){
                return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
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
    if([[UIApplication sharedApplication] canOpenURL:URL]){
        if(@available(iOS 10, *)){
            [[UIApplication sharedApplication] openURL:URL options:[NSDictionary dictionary] completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

+ (void)openSettings
{
    [GKAppUtils openCompatURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
