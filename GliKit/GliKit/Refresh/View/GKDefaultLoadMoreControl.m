//
//  GKDefaultLoadMoreControl.m
//  GliKit
//
//  Created by luohaixiong on 2018/7/20.
//  Copyright © 2018年 罗海雄. All rights reserved.
//

#import "GKDefaultLoadMoreControl.h"
#import "UIView+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation GKDefaultLoadMoreControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super initWithScrollView:scrollView];
    if(self){
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        _textLabel.font = [UIFont systemFontOfSize:14.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
        
        _showIndicatorView = YES;
        
        [self setState:GKDataControlStateNoData];
    }
    
    return self;
}

- (void)setIsHorizontal:(BOOL)isHorizontal
{
    [super setIsHorizontal:isHorizontal];
    _textLabel.numberOfLines = self.isHorizontal ? 0 : 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if(self.isHorizontal){
        CGFloat contentWidth = (_indicatorView.isAnimating ? (_indicatorView.gkWidth + + 3.0) : 0) + _textLabel.gkWidth;
        _indicatorView.gkLeft = (self.criticalPoint - contentWidth) / 2;
        _textLabel.gkLeft = (_indicatorView.isAnimating ? _indicatorView.gkRight + 3.0 : _indicatorView.gkLeft);
    }else{
        _indicatorView.gkTop = (self.criticalPoint - _indicatorView.gkHeight) / 2;
        _textLabel.gkTop = (self.criticalPoint - _textLabel.gkHeight) / 2;
    }
}

// MARK: - Super Method

- (void)onStateChange:(GKDataControlState)state
{
    [super onStateChange:state];
    switch (state){
        case GKDataControlStateNormal : {
            _textLabel.text = [self titleForState:state];
            [_indicatorView stopAnimating];
            [self updatePosition];
        }
            break;
        case GKDataControlStatePulling : {
            _textLabel.text = [self titleForState:state];
            [_indicatorView stopAnimating];
            [self updatePosition];
        }
            break;
        case GKDataControlStateNoData :
        {
            [_indicatorView stopAnimating];
            _textLabel.text = [self titleForState:state];
            _textLabel.hidden = !self.shouldStayWhileNoData;
            [self updatePosition];
        }
            break;
        case GKDataControlStateLoading : {
            _textLabel.text = [self titleForState:state];
            if(_showIndicatorView){
                [_indicatorView startAnimating];
            }
            [self updatePosition];
        }
            break;
        case GKDataControlStateReachCirticalPoint : {
            _textLabel.text = [self titleForState:state];
            [self updatePosition];
        }
            break;
        default:
            break;
    }
}

///更新位置
- (void)updatePosition
{
    if(self.isHorizontal){
        CGFloat height = _indicatorView.gkHeight;
        CGSize size = [_textLabel.text gkStringSizeWithFont:_textLabel.font contraintWith:18];
        size.width += 1.0;
        size.height += 1.0;
        _indicatorView.gkTop = (self.gkHeight - height) / 2.0;
        
        CGRect frame = _textLabel.frame;
        frame.origin.y = (self.gkHeight - size.height) / 2.0;
        frame.size.width = size.width;
        frame.size.height = size.height;
        _textLabel.frame = frame;
    }else{
        CGFloat width = _indicatorView.isAnimating ? _indicatorView.gkWidth : 0;
        CGSize size = [_textLabel.text gkStringSizeWithFont:_textLabel.font contraintWith:self.gkWidth - width];
        size.width += 1.0;
        size.height += 1.0;
        _indicatorView.gkLeft = (self.gkWidth - size.width - width) / 2.0;
        
        CGRect frame = _textLabel.frame;
        frame.origin.x = _indicatorView.gkLeft + width + 3.0;
        frame.size.width = self.gkWidth - _indicatorView.gkLeft - width;
        frame.size.height = size.height;
        _textLabel.frame = frame;
    }
}
@end
