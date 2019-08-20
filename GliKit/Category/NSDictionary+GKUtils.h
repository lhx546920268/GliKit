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
- (NSString*)gk_stringForKey:(id<NSCopying>) key;

/**
 获取可转成数字的对象 NSNumber 、NSString
 */
- (id)gk_numberForKey:(id<NSCopying>) key;

/**
 获取整数
 */
- (int)gk_intForKey:(id<NSCopying>) key;

/**
 获取整数
 */
- (NSInteger)gk_integerForKey:(id<NSCopying>) key;

/**
 获取小数点
 */
- (float)gk_floatForKey:(id<NSCopying>) key;

/**
 获取小数点
 */
- (double)gk_doubleForKey:(id<NSCopying>) key;

/**
 获取布尔
 */
- (BOOL)gk_boolForKey:(id<NSCopying>) key;


/**
 获取字典
 */
- (NSDictionary*)gk_dictionaryForKey:(id<NSCopying>) key;

/**
 获取数组
 */
- (NSArray*)gk_arrayForKey:(id<NSCopying>) key;

@end

