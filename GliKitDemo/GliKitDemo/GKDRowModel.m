//
//  GKDRowModel.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRowModel.h"
#import <BackgroundTasks/BackgroundTasks.h>

@interface GKInnterModel : NSObject

@property(nonatomic, strong) NSString *name;

- (void)test;

@end

@implementation GKInnterModel

- (void)test
{
    NSLog(@"test %@", self.name);
}

@end

@implementation GKDRowModel

@synthesize className;

GKConvenientSecureCoder
GKConvenientCopying

+ (instancetype)modelWithTitle:(NSString *)title clazz:(NSString*)clazz
{
    GKDRowModel *model = GKDRowModel.new;
    model.title = title;
    model.className = clazz;
    
    return model;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    GKDRowModel *model = [GKDRowModel new];
    
    return model;
}

- (NSString *)description
{
    return _stringValue;
}

- (void)setBoolValue:(BOOL)boolValue
{
    
}

- (BOOL)boolValue
{
    return YES;
}

@end
