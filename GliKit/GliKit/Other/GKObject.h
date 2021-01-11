//
//  GKObject.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKObject: NSObject

///通过字典创建
+ (instancetype)modelFromDictionary:(nullable NSDictionary*) dic;

///通过数组字典创建一个数组 如果array.count == 0 返回nil
+ (nullable NSMutableArray*)modelsFromArray:(nullable NSArray<NSDictionary*>*) array;

///通过数组字典创建一个数组 如果array.count == 0 返回nil 返回的数组长度不会超过maxCount
+ (nullable NSMutableArray*)modelsFromArray:(nullable NSArray<NSDictionary*>*) array maxCount:(int) maxCount;

///子类要重写这个来设置对应的值
- (void)setDictionary:(nullable NSDictionary*) dic;

@end

NS_ASSUME_NONNULL_END

