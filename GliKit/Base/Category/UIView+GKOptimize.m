//
//  UIView+GKOptimize.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/8/12.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIView+GKOptimize.h"

@implementation UIView (GKOptimize)

- (void)gkAvoidColorBlended
{
#ifdef DEBUG
    NSAssert(self.superview, @"gk_avoidColorBlended superview can't be nil");
#endif
    [self gkAvoidColorBlendedForColor:self.superview.backgroundColor];
}

- (void)gkAvoidColorBlendedForColor:(UIColor *)color
{
    if(!color){
        color = UIColor.clearColor;
    }
    if([self isKindOfClass:UILabel.class]){
        self.backgroundColor = color;
        self.layer.masksToBounds = YES;
    }else if ([self isKindOfClass:UIButton.class]){
        UIButton *btn = (UIButton*)self;
        btn.titleLabel.backgroundColor = color;
        btn.titleLabel.layer.masksToBounds = YES;
    }else{
        self.backgroundColor = color;
    }
}

@end
