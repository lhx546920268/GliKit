//
//  NSJSONSerialization+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSJSONSerialization (GKUtils)

/**
 便利的Json解析
 
 *@param string Json数据
 *@return NSDictionary
 */
+ (nullable NSDictionary*)gkDictionaryFromString:(NSString*) string;

/**
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSDictionary
 */
+ (nullable NSDictionary*)gkDictionaryFromData:(NSData*) data;

/**
 便利的Json解析
 
 *@param string Json数据
 *@return NSArray
 */
+ (nullable NSArray*)gkArrayFromString:(NSString*) string;

/**
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSArray
 */
+ (nullable NSArray*)gkArrayFromData:(NSData*) data;

/**
 把Json 对象转换成 json字符串
 
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (nullable NSString*)gkStringFromObject:(id) object;

/**
 把 json 对象转换成 json二进制
 
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (nullable NSData*)gkDataFromObject:(id) object;

@end

NS_ASSUME_NONNULL_END
