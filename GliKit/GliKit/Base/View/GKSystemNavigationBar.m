//
//  GKSystemNavigationBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKSystemNavigationBar.h"
#import "UIColor+GKTheme.h"

@implementation GKSystemNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initParams];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initParams];
    }
    return self;
}

- (void)initParams
{
    self.enable = YES;
    //把导航栏变成透明
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [UIImage new];
    self.tintColor = UIColor.gkNavigationBarTintColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!self.enable)
        return nil;
    return [super hitTest:point withEvent:event];
}

@end
