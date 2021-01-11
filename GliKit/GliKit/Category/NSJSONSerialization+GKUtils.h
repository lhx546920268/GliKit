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

///获取json字典
+ (nullable NSDictionary*)gkDictionaryFromString:(NSString*) string;
+ (nullable NSDictionary*)gkDictionaryFromData:(NSData*) data;

//获取json数组
+ (nullable NSArray*)gkArrayFromString:(NSString*) string;
+ (nullable NSArray*)gkArrayFromData:(NSData*) data;

///获取json字符串
+ (nullable NSString*)gkStringFromObject:(id) object;

///获取json二进制
+ (nullable NSData*)gkDataFromObject:(id) object;

@end

NS_ASSUME_NONNULL_END
