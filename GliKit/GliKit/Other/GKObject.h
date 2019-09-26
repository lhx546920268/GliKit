//
//  GKObject.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///通过字典初始化
@interface GKObject : NSObject

+ (instancetype)modelFromDictionary:(nullable NSDictionary*) dic NS_REQUIRES_SUPER;


/**
 通过数组字典创建一个数组

 @param array 包含字典的数组
 @return 如果array 大于0 返回包含对应子类的数组，否则返回nil
 */
+ (nullable NSMutableArray*)modelsFromArray:(nullable NSArray<NSDictionary*>*) array;


/**
 通过数组字典创建一个数组

 @param array 包含字典的数组
 @param maxCount 最大数量
 @return 如果array 大于0 返回包含对应子类的数组，否则返回nil
 */
+ (nullable NSMutableArray*)modelsFromArray:(nullable NSArray<NSDictionary*>*) array maxCount:(int) maxCount;

/**
 子类要重写这个
 
 @param dic 包含数据的字典
 */
- (void)setDictionary:(nullable NSDictionary*) dic;

@end

NS_ASSUME_NONNULL_END

