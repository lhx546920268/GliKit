//
//  GKLRUCache.h
//  GliKit
//
//  Created by xiaozhai on 2023/8/2.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///lur缓存
@interface GKLRUCache<KeyType, ObjectType> : NSObject

///最大容量
@property(nonatomic, readonly) NSUInteger capacity;

///如果object为空，删除
- (void)setObject:(nullable ObjectType)object forKey:(KeyType<NSCopying>)key;

///删除并返回
- (nullable ObjectType)removeObjectForKey:(KeyType<NSCopying>)key;
- (nullable ObjectType)objectForKey:(KeyType<NSCopying>)key;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

///初始化
- (instancetype)initWithCapacity:(NSUInteger) capacity;

@end

NS_ASSUME_NONNULL_END
