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

///objectAtIndex 如果index 越界，返回nil
- (nullable ObjectType)gkObjectAtIndex:(NSUInteger) index;

///objectAtIndex 如果index 越界，返回nil 并且判断返回的值是否是对应类型
- (nullable ObjectType)gkObjectAtIndex:(NSUInteger) index clazz:(Class) clazz;

///判断数组中是否存在某个字符串
- (BOOL)gkContainString:(nullable NSString *)string;

///过滤数组 数组本身不变 返回一个新的数组
- (NSArray<ObjectType>*)gkFilteredArrayUsingBlock:(BOOL(^)(ObjectType obj)) block;

@end

@interface NSMutableArray<ObjectType> (GKUtils)

///添加前会判断数组中是否已存在 返回不成功则表示已存在
- (BOOL)gkAddNotExistObject:(nullable ObjectType) obj;

///添加前会判断数组中是否已存在 不成功则表示已存在
- (BOOL)gkInsertNotExistObject:(nullable ObjectType) obj atIndex:(NSInteger) index;

///添加不为空的对象
- (void)gkAddNotNilObject:(nullable ObjectType) obj;

/// 过滤数组
/// @param block 用来过滤的块，返回是否保留对应的元素
- (void)gkFilterUsingBlock:(BOOL(^)(ObjectType obj)) block;

@end

NS_ASSUME_NONNULL_END

