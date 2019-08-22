//
//  NSDictionary+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GKUtils)

/**
 去空获取对象 并且如果对象是NSNumber将会转化成字符串
 */
- (NSString*)gkStringForKey:(id<NSCopying>) key;

/**
 获取可转成数字的对象 NSNumber 、NSString
 */
- (id)gkNumberForKey:(id<NSCopying>) key;

/**
 获取整数
 */
- (int)gkIntForKey:(id<NSCopying>) key;

/**
 获取整数
 */
- (NSInteger)gkIntegerForKey:(id<NSCopying>) key;

/**
 获取小数点
 */
- (float)gkFloatForKey:(id<NSCopying>) key;

/**
 获取小数点
 */
- (double)gkDoubleForKey:(id<NSCopying>) key;

/**
 获取布尔
 */
- (BOOL)gkBoolForKey:(id<NSCopying>) key;


/**
 获取字典
 */
- (NSDictionary*)gkDictionaryForKey:(id<NSCopying>) key;

/**
 获取数组
 */
- (NSArray*)gkArrayForKey:(id<NSCopying>) key;

@end

