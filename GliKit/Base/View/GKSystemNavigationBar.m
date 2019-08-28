//
//  GKSystemNavigationBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/6/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKSystemNavigationBar.h"

@implementation GKSystemNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.enable = YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!self.enable)
        return nil;
    return [super hitTest:point withEvent:event];
}

@end
