//
//  NSArray+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///数组扩展
@interface NSArray<__covariant ObjectType> (GKUtils)

/**
 objectAtIndex 如果index 越界，返回nil
 
 @param index 下标
 @return 对应 object
 */
- (nullable ObjectType)gkObjectAtIndex:(NSUInteger) index;

/**
 objectAtIndex 如果index 越界，返回nil 并且判断返回的值是否是对应类型
 
 @param index index 下标
 @param clazz 要获取值得类型
 @return object
 */
- (nullable ObjectType)gkObjectAtIndex:(NSUInteger) index clazz:(Class) clazz;

/**
 判断数组中是否存在某个字符串
 
 @param string 要判断的字符串
 @return 是否存在
 */
- (BOOL)gkContainString:(nullable NSString *)string;

/**
 过滤数组 数组本身不变 返回一个新的数组
 
 @param block 用来过滤的块，返回是否保留对应的元素
 @return 一个新的数组
 */
- (NSArray<ObjectType>*)gkFilteredArrayUsingBlock:(BOOL(^)(ObjectType obj)) block;

@end

@interface NSMutableArray<ObjectType> (GKUtils)

/**
 添加前会判断数组中是否已存在
 
 @param obj 要加入的对象
 @return 是否加入成功 不成功则表示已存在
 */
- (BOOL)gkAddNotExistObject:(nullable ObjectType) obj;

/**
 添加前会判断数组中是否已存在
 
 @param obj 要加入的对象
 @param index 插入的位置
 @return 是否加入成功 不成功则表示已存在
 */
- (BOOL)gkInsertNotExistObject:(nullable ObjectType) obj atIndex:(NSInteger) index;

/**
 添加不为空的对象
 
 @param obj 要加入的对象
 */
- (void)gkAddNotNilObject:(nullable ObjectType) obj;

/**
 过滤数组
 
 @param block 用来过滤的块，返回是否保留对应的元素
 */
- (void)gkFilterUsingBlock:(BOOL(^)(ObjectType obj)) block;

@end

NS_ASSUME_NONNULL_END

