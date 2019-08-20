//
//  NSAttributedString+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSAttributedString+GKUtils.h"

@implementation NSAttributedString (GKUtils)

- (CGSize)gk_boundsWithConstraintWidth:(CGFloat) width
{
    return [self boundingRectWithSize:CGSizeMake(width, 8388608.0) options:NSStringDrawingTruncatesLastVisibleLine |
            NSStringDrawingUsesLineFragmentOrigin |
            NSStringDrawingUsesFontLeading  context:nil].size;
}

@end
