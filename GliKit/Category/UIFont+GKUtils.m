//
//  UIFont+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIFont+GKUtils.h"

@implementation UIFont (GKUtils)

+ (UIFont*)appFontWithSize:(CGFloat) fontSize
{
    return [UIFont systemFontOfSize:fontSize];
}

- (BOOL)isEqualToFont:(UIFont*) font
{
    if(!font)
        return NO;
    
    return [self.fontName isEqualToString:font.fontName] && self.pointSize == font.pointSize;
}

@end
