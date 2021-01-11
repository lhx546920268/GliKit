//
//  UIApplication+GKTheme.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKRefreshControl.h"
#import "UIView+GKUtils.h"
#import "NSString+GKUtils.h"

@interface GKRefreshControl ()

@end

@implementation GKRefreshControl

- (instancetype)initWithScrollView:(UIScrollView*) scrollView
{
    self = [super initWithScrollView:scrollView];
    if(self){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setState:GKDataControlStateNormal];
    }
    
    return self;
}

- (void)initViews
{
    [super initViews];
    self.criticalPoint = 60;
    [self setTitle:@"下拉刷新" forState:GKDataControlStateNormal];
    [self setTitle:@"加载中..." forState:GKDataControlStateLoading];
    [self setTitle:@"松开即可刷新" forState:GKDataControlStateReachCirticalPoint];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.height = MAX(self.criticalPoint, - self.scrollView.contentOffset.y + self.originalContentInset.top);
    
    frame.origin.y = - frame.size.height;
    self.frame = frame;
}

// MARK: - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat y = self.scrollView.contentOffset.y;
    if(y <= 0.0f  && [keyPath isEqualToString:GKDataControlOffset]){
        
        if(self.state != GKDataControlStateLoading){
            
            if(!self.animating){
                CGFloat criticalPoint = -self.realCriticalPoint;
                if(self.scrollView.dragging){
                    if (y == 0.0f){
                        
                        [self setState:GKDataControlStateNormal];
                    }else if (y > criticalPoint){
                        
                        [self setState:GKDataControlStatePulling];
                    }else{
                        
                        [self setState:GKDataControlStateReachCirticalPoint];
                    }
                }else if(y <= criticalPoint || self.state == GKDataControlStateReachCirticalPoint){
                    
                    [self startLoading];
                }
            }
        }
        
        if(!self.animating){
            [self setNeedsLayout];
        }
    }
}

- (CGFloat)realCriticalPoint
{
    CGFloat point = self.criticalPoint;
    if(@available(iOS 11, *)){
        point += self.scrollView.adjustedContentInset.top;
    }
    return point;
}

// MARK: - super method

- (void)startLoading
{
    [super startLoading];
    if(self.animating)
        return;
    
    self.animating = YES;
    [UIView animateWithDuration:0.25 animations:^(void){
        
        UIEdgeInsets inset = self.originalContentInset;
        inset.top = self.criticalPoint;
        self.scrollView.contentInset = inset;
        self.scrollView.contentOffset = CGPointMake(0, - self.criticalPoint);
        
    }completion:^(BOOL finish){
         [self setState:GKDataControlStateLoading];
         self.animating = NO;
    }];
}

- (void)onStateChange:(GKDataControlState)state
{
    [super onStateChange:state];
    switch (state) {
        case GKDataControlStateLoading : {
            if(self.loadingDelay > 0){
                [self performSelector:@selector(onStartLoading) withObject:nil afterDelay:self.loadingDelay];
            }else{
                [self onStartLoading];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
