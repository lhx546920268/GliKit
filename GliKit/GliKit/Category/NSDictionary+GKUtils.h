//
//  NSDictionary+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (GKUtils)

///去空获取对象 并且如果对象是NSNumber将会转化成字符串
- (nullable NSString*)gkStringForKey:(id<NSCopying>) key;
- (NSString*)gkStringForKey:(id<NSCopying>) key defaultValue:(NSString*) defaultValue;

///去空获取对象 并且如果对象是NSNumber将会转化成字符串，如果 == nil 返回 @""
- (NSString*)gkNonnullStringForKey:(id<NSCopying>) key;

///获取可转成数字的对象 NSNumber 、NSString
- (nullable id)gkNumberForKey:(id<NSCopying>) key;

///获取整数
- (int)gkIntForKey:(id<NSCopying>) key;
- (int)gkIntForKey:(id<NSCopying>) key defaultValue:(int) defaultValue;
- (NSInteger)gkIntegerForKey:(id<NSCopying>) key;
- (NSInteger)gkIntegerForKey:(id<NSCopying>) key defaultValue:(NSInteger) defaultValue;

///获取小数
- (float)gkFloatForKey:(id<NSCopying>) key;
- (float)gkFloatForKey:(id<NSCopying>) key defaultValue:(float) defaultValue;
- (double)gkDoubleForKey:(id<NSCopying>) key;
- (double)gkDoubleForKey:(id<NSCopying>) key defaultValue:(double) defaultValue;

///获取布尔
- (BOOL)gkBoolForKey:(id<NSCopying>) key;
- (BOOL)gkBoolForKey:(id<NSCopying>) key defaultValue:(BOOL) defaultValue;

///获取字典
- (nullable NSDictionary*)gkDictionaryForKey:(id<NSCopying>) key;

///获取数组
- (nullable NSArray*)gkArrayForKey:(id<NSCopying>) key;

/// 过滤字典 字典本身不变 返回一个新的字典
/// @param block 用来过滤的块，返回是否保留对应的元素
- (NSDictionary<KeyType, ObjectType>*)gkFilteredDictionaryUsingBlock:(BOOL(^)(KeyType key, ObjectType obj)) block;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (GKUtils)

/// 过滤字典
/// @param block 用来过滤的块，返回是否保留对应的元素
- (void)gkFilterUsingBlock:(BOOL(^)(KeyType key, ObjectType obj)) block;

@end

NS_ASSUME_NONNULL_END

