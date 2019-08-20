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
+ (NSDictionary*)gk_dictionaryFromString:(NSString*) string;

/**
 
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSDictionary
 */
+ (NSDictionary*)gk_dictionaryFromData:(NSData*) data;

/**
 
 便利的Json解析
 
 *@param string Json数据
 *@return NSArray
 */
+ (NSArray*)gk_arrayFromString:(NSString*) string;

/**
 
 便利的Json解析 避免了 data = nil时，抛出异常
 
 *@param data Json数据
 *@return NSArray
 */
+ (NSArray*)gk_arrayFromData:(NSData*) data;

/**
 把Json 对象转换成 json字符串
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (NSString*)gk_stringFromObject:(id) object;

/**
 把 json 对象转换成 json二进制
 *@param object 要转换成json的对象
 *@return json字符串
 */
+ (NSData*)gk_dataFromObject:(id) object;

@end
