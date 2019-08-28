//
//  NSAttributedString+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSAttributedString+GKUtils.h"

@implementation NSAttributedString (GKUtils)

- (CGSize)gkBoundsWithConstraintWidth:(CGFloat) width
{
    return [self boundingRectWithSize:CGSizeMake(width, 8388608.0) options:NSStringDrawingTruncatesLastVisibleLine |
            NSStringDrawingUsesLineFragmentOrigin |
            NSStringDrawingUsesFontLeading context:nil].size;
}

@end
