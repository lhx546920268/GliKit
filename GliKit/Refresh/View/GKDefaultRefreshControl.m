//
//  GKDefaultRefreshControl.m
//  GliKit
//
//  Created by luohaixiong on 2018/7/20.
//  Copyright © 2018年 罗海雄. All rights reserved.
//

#import "GKDefaultRefreshControl.h"
#import "UIView+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation GKDefaultRefreshControl

- (id)initWithScrollView:(UIScrollView*) scrollView
{
    self = [super initWithScrollView:scrollView];
    if(self){
        
        _showIndicatorView = YES;
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(_indicatorView.gkRight, 0, self.gkWidth - _indicatorView.gkRight, _indicatorView.gkHeight)];
        _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusLabel.font = [UIFont systemFontOfSize:13.0f];
        _statusLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        _statusLabel.backgroundColor = [UIColor clearColor];
        [_statusLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_statusLabel];
        
        [self updatePosition];
        
        [self setState:GKDataControlStateNormal];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = (self.criticalPoint - _indicatorView.gkHeight) / 2.0;
    
    _indicatorView.gkTop = self.gkHeight - _statusLabel.gkHeight - margin;
    _statusLabel.gkTop = _indicatorView.gkTop;
}

//MARK: Super Method

- (void)onStateChange:(GKDataControlState)state
{
    [super onStateChange:state];
    switch (state) {
        case GKDataControlStatePulling : {
            
            if(!self.animating){
                _statusLabel.text = [self titleForState:state];
                [self updatePosition];
            }
        }
            break;
        case GKDataControlStateReachCirticalPoint : {
            
            _statusLabel.text = [self titleForState:state];
            [self updatePosition];
        }
            break;
        case GKDataControlStateNormal :
        case GKDataControlStateFail : {
            
            if(!self.animating){
                _statusLabel.text = [self titleForState:state];
                [self updatePosition];
            }
        }
            
            break;
        case GKDataControlStateLoading : {
            
            _statusLabel.text = [self titleForState:state];
            if(self.showIndicatorView){
                [_indicatorView startAnimating];
            }
            [self updatePosition];
        }
            break;
        case GKDataControlStateNoData : {
            
        }
            break;
    }
}

- (void)stopLoading
{
    [super stopLoading];
    
    [_indicatorView stopAnimating];
    _statusLabel.text = self.finishText;
    [self updatePosition];
}

- (void)updatePosition
{
    CGFloat width = _indicatorView.isAnimating ? _indicatorView.gkWidth : 0;
    CGSize size = [_statusLabel.text gk_stringSizeWithFont:_statusLabel.font contraintWith:self.frame.size.width - width];
    _indicatorView.gkLeft = (self.frame.size.width - size.width - width) / 2.0;
    
    CGRect frame = _indicatorView.frame;
    frame.origin.x = _indicatorView.gkLeft + width + 3.0;
    frame.size.width = self.frame.size.width - _indicatorView.gkLeft - width;
    _statusLabel.frame = frame;
}


@end
