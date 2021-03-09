//
//  GKDLoadMonitor.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2021/3/9.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKDLoadMonitor.h"
#import <mach-o/loader.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <string.h>

unsigned int count;
const char **classes;

static NSMutableArray *_loadInfoArray;

@implementation GKDLoadMonitor

+ (NSArray *)executeTimes
{
    return _loadInfoArray;
}

+ (void)load {
        
    _loadInfoArray = [[NSMutableArray alloc] init];
    
    CFAbsoluteTime time1 =CFAbsoluteTimeGetCurrent();
    
    int imageCount = (int)_dyld_image_count();
    
    for(int iImg = 0; iImg < imageCount; iImg++) {
        
        const char* path = _dyld_get_image_name((unsigned)iImg);
        NSString *imagePath = [NSString stringWithUTF8String:path];
        
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* bundlePath = [mainBundle bundlePath];
        
        if ([imagePath containsString:bundlePath] && ![imagePath containsString:@".dylib"]) {
            classes = objc_copyClassNamesForImage(path, &count);
            
            for (int i = 0; i < count; i++) {
                NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
                if (![className isEqualToString:@""] && className) {
                    Class class = object_getClass(NSClassFromString(className));
                    
                    SEL originalSelector = @selector(load);
                    SEL swizzledSelector = @selector(LDAPM_Load);
                    
                    Method originalMethod = class_getClassMethod(class, originalSelector);
                    Method swizzledMethod = class_getClassMethod([GKDLoadMonitor class], swizzledSelector);
                    
                    BOOL hasMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
                    
                    if (!hasMethod) {
                        BOOL didAddMethod = class_addMethod(class,
                                                            swizzledSelector,
                                                            method_getImplementation(swizzledMethod),
                                                            method_getTypeEncoding(swizzledMethod));
                        
                        if (didAddMethod) {
                            swizzledMethod = class_getClassMethod(class, swizzledSelector);
                            
                            method_exchangeImplementations(originalMethod, swizzledMethod);
                        }
                    }
                    
                }
            }
        }
    }

    CFAbsoluteTime time2 =CFAbsoluteTimeGetCurrent();
    
     NSLog(@"Hook Time:%f",(time2 - time1) * 1000);
}

+ (void)LDAPM_Load {
    
    CFAbsoluteTime start =CFAbsoluteTimeGetCurrent();
    
    [self LDAPM_Load];
    
    CFAbsoluteTime end =CFAbsoluteTimeGetCurrent();
    // 时间精度 us
    NSDictionary *infoDic = @{@"time": @(end - start),
                              @"name":NSStringFromClass([self class])
                              };
    
    [_loadInfoArray addObject:infoDic];
}


@end
