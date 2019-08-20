//
//  GKAppUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/26.
//  Copyright © 2019 xiaozhai. All rights reserved.
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

///当前设备唯一标识符
static NSString *sharedUUID = nil;

//存放uuid的钥匙串
static NSString *GKKeychainService = @"com.zegobird.my";
static NSString *GKKeychainUUIDKey = @"zegobirdUUID";

@implementation GKAppUtils

+ (NSString*)appVersion
{
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
    
    return [dic objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isTestApp
{
    return GKAppUtils.appVersion.length > 7;
}

+ (NSString*)appName
{
    static NSDictionary *infoStringsDictionary = nil;
    static dispatch_once_t once = 0;
    
    dispatch_once(&once, ^(void){
        
        infoStringsDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InfoPlist" ofType:@"strings"]];
    });
    
    NSString *name = [infoStringsDictionary objectForKey:@"CFBundleDisplayName"];
    if([NSString isEmpty:name]){
        name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    }
    
    return name;
}

+ (UIImage*)appIcon
{
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
    NSString *iconName = [[dic valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    
    return [UIImage imageNamed:iconName];
}

+ (NSString*)uuid
{
    if([NSString isEmpty:sharedUUID]){
        
        NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@%@", GKKeychainService, GKKeychainUUIDKey]];
        if([NSString isEmpty:uuid]){
            uuid = [GKSSKeychain passwordForService:GKKeychainService account:GKKeychainUUIDKey error:nil];
        }
        
        if([NSString isEmpty:uuid]){
            CFUUIDRef uuidRef = CFUUIDCreate(NULL);
            CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
            CFRelease(uuidRef);
            uuid = [NSString stringWithString:(__bridge NSString*)uuidStringRef];
            CFRelease(uuidStringRef);
            
            [GKSSKeychain setPassword:uuid forService:GKKeychainService account:GKKeychainUUIDKey error:nil];
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:[NSString stringWithFormat:@"%@%@", GKKeychainService, GKKeychainUUIDKey]];
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
