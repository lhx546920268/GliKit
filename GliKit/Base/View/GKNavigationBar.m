//
//  GKNavigationBar.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKNavigationBar.h"

@interface GKNavigationBar ()

///背景
@property(nonatomic, readonly) UIView *backgroundView;

@end

@implementation GKNavigationBar

@synthesize shadowView = _shadowView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _backgroundView = [UIView new];
        _backgroundView.alpha = 0.95;
        _backgroundView.backgroundColor = UIColor.appNavigationBarBackgroundColor;
        [self addSubview:_backgroundView];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }

    return self;
}

- (UIView *)shadowView
{
    if(!_shadowView){
        _shadowView = [UIView new];
        _shadowView.backgroundColor = UIColor.appSeparatorColor;
        [self addSubview:_shadowView];
        
        [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.equalTo(UIApplication.appSeparatorHeight);
        }];
    }
    
    return _shadowView;
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:1.0];
    self.backgroundView.alpha = alpha * 0.95;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:UIColor.clearColor];
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

@end
