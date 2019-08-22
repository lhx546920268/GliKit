//
//  NSJSONSerialization+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSJSONSerialization (GKUtils)

/**
 
 便利的Json解析
 
 *@param string Json数据
 *@return NSDictionary
 */
+ (NSDictionary*)gkDictionaryFromString:(NSString*) string;

/**
 
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSDictionary
 */
+ (NSDictionary*)gkDictionaryFromData:(NSData*) data;

/**
 
 便利的Json解析
 
 *@param string Json数据
 *@return NSArray
 */
+ (NSArray*)gkArrayFromString:(NSString*) string;

/**
 
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSArray
 */
+ (NSArray*)gkArrayFromData:(NSData*) data;

/**
 把Json 对象转换成 json字符串
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (NSString*)gkStringFromObject:(id) object;

/**
 把 json 对象转换成 json二进制
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (NSData*)gkDataFromObject:(id) object;

@end
