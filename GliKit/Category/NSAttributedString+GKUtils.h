//
//  NSAttributedString+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (GKUtils)

/**
 获取富文本框大小
 *@param width 每行最大宽度
 *@return 富文本框大小
 */
- (CGSize)gkBoundsWithConstraintWidth:(CGFloat) width;

@end
