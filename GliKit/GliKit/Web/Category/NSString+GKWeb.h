//
//  NSString+GKWeb.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/16.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

///web有关的字符串扩展
@interface NSString (GKWeb)

/**
 适配屏幕的html字符串，把它加在html的前面
 */
+ (NSString*)adjustScreenHtmlString;

@end

