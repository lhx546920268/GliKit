//
//  UIFont+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///字体扩展
@interface UIFont (GKUtils)

/**
 当前app字体
 */
+ (UIFont*)appFontWithSize:(CGFloat) fontSize;

/**
 字体是否相等
 */
- (BOOL)isEqualToFont:(UIFont*) font;

@end
