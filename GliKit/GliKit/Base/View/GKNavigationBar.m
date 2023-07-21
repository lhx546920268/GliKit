//
//  GKNavigationBar.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKNavigationBar.h"
#import "GKBaseDefines.h"
#import "UIApplication+GKTheme.h"
#import "UIColor+GKTheme.h"
#import "NSString+GKUtils.h"
#import "UIFont+GKTheme.h"
#import "UIView+GKStateUtils.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"
#import "UIColor+GKUtils.h"

@interface GKNavigationBar ()

///标题大小
@property(nonatomic, assign) CGSize titleSize;

///标题视图大小
@property(nonatomic, assign) CGSize titleViewSize;

///内容视图
@property(nonatomic, strong) UIView *contentView;

@end

@implementation GKNavigationBar

@synthesize shadowView = _shadowView;
@synthesize titleLabel = _titleLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.tintColor = UIColor.gkNavigationBarTintColor;
        _backgroundView = [UIView new];
        _backgroundView.alpha = 0.95;
        _backgroundView.backgroundColor = UIColor.gkNavigationBarBackgroundColor;
        [self addSubview:_backgroundView];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }

    return self;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
    }
    return _contentView;;
}

- (UIView *)shadowView
{
    if(!_shadowView){
        _shadowView = [UIView new];
        _shadowView.backgroundColor = UIColor.gkSeparatorColor;
        [self addSubview:_shadowView];
        
        [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.mas_equalTo(UIApplication.gkSeparatorHeight);
        }];
    }
    
    return _shadowView;
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:1.0];
    self.backgroundView.alpha = alpha;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:UIColor.clearColor];
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void)tintColorDidChange
{
    [self setTintColorForItem:self.leftItemView];
    [self setTintColorForItem:self.rightItemView];
}

///设置item tintColor
- (void)setTintColorForItem:(UIView*) item
{
    UIColor *tintColor = self.tintColor;
    if([item isKindOfClass:UIButton.class]){
        UIButton *btn = (UIButton*)item;
        if([btn imageForState:UIControlStateNormal]){
            [btn gkSetTintColor:tintColor forState:UIControlStateNormal];
            [btn gkSetTintColor:[tintColor gkColorWithAlpha:0.3] forState:UIControlStateHighlighted];
            
        }else{
            [btn setTitleColor:tintColor forState:UIControlStateNormal];
            [btn setTitleColor:[tintColor gkColorWithAlpha:0.3] forState:UIControlStateHighlighted];
        }
    }else{
        item.tintColor = tintColor;
    }
}

- (UIButton *)setLeftItemWithImage:(UIImage *)image target:(id) target action:(SEL)action
{
    UIButton *btn = [self.class itemWithImage:image target:target action:action];
    self.leftItemView = btn;
    return btn;
}

- (UIButton *)setLeftItemWithTitle:(NSString *)title target:(id) target action:(SEL)action
{
    UIButton *btn = [self.class itemWithTitle:title target:target action:action];
    self.leftItemView = btn;
    return btn;
}

- (UIButton *)setRightItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *btn = [self.class itemWithImage:image target:target action:action];
    self.rightItemView = btn;
    return btn;
}

- (UIButton *)setRightItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [self.class itemWithTitle:title target:target action:action];
    self.rightItemView = btn;
    return btn;
}

- (void)setLeftItemView:(UIView *)leftItemView
{
    if (_leftItemView != leftItemView) {
        [_leftItemView removeFromSuperview];
        _leftItemView = leftItemView;
        
        if (_leftItemView) {
            [self setTintColorForItem:_leftItemView];
            [self.contentView addSubview:_leftItemView];
        }
        [self setNeedsLayout];
    }
}

- (void)setLeftItemEnabled:(BOOL)leftItemEnabled
{
    if ([_leftItemView isKindOfClass:UIControl.class]) {
        UIControl *control = (UIControl*)_leftItemView;
        control.enabled = leftItemEnabled;
    } else {
        _leftItemView.userInteractionEnabled = leftItemEnabled;
    }
}

- (BOOL)leftItemEnabled
{
    if ([_leftItemView isKindOfClass:UIControl.class]) {
        UIControl *control = (UIControl*)_leftItemView;
        return control.enabled;
    } else {
        return _leftItemView.userInteractionEnabled;
    }
}

- (void)setRightItemView:(UIView *)rightItemView
{
    if (_rightItemView != rightItemView) {
        [_rightItemView removeFromSuperview];
        _rightItemView = rightItemView;
        
        if (_rightItemView) {
            [self setTintColorForItem:_rightItemView];
            [self.contentView addSubview:_rightItemView];
        }
        [self setNeedsLayout];
    }
}

- (void)setRightItemEnabled:(BOOL)rightItemEnabled
{
    if ([_rightItemView isKindOfClass:UIControl.class]) {
        UIControl *control = (UIControl*)_rightItemView;
        control.enabled = rightItemEnabled;
    } else {
        _rightItemView.userInteractionEnabled = rightItemEnabled;
    }
}

- (BOOL)rightItemEnabled
{
    if ([_rightItemView isKindOfClass:UIControl.class]) {
        UIControl *control = (UIControl*)_rightItemView;
        return control.enabled;
    } else {
        return _rightItemView.userInteractionEnabled;
    }
}

- (void)setTitle:(NSString *)title
{
    if (!GKStringEqual(_title, title)) {
        _title = [title copy];
        self.titleLabel.text = _title;
        self.titleSize = CGSizeMake([_title gkStringSizeWithFont:self.titleLabel.font].width, UIApplication.gkNavigationBarHeight);
        [_titleView removeFromSuperview];
        _titleView = nil;
        [self setNeedsLayout];
    }
}

- (UILabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = UIFont.gkNavigationBarItemFont;
        _titleLabel.textColor = UIColor.gkNavigationBarTitleColor;
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (void)setTitleView:(UIView *)titleView
{
    if (_titleView != titleView) {
        [_titleView removeFromSuperview];
        _titleView = titleView;
        if (_titleView) {
            [self.contentView addSubview:_titleView];
        }
        
        self.titleViewSize = _titleView.bounds.size;
        _titleLabel.hidden = _titleView != nil;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_leftItemView || _rightItemView || _titleLabel || _titleView) {
        
        _contentView.frame = CGRectMake(0, self.gkHeight - UIApplication.gkNavigationBarHeight, self.gkWidth, UIApplication.gkNavigationBarHeight);
        CGFloat width = _contentView.gkWidth;
        CGFloat height = _contentView.gkHeight;
        
        CGFloat leftWidth = _leftItemView.gkWidth;
        CGFloat rightWidth = _rightItemView.gkWidth;
        _leftItemView.center = CGPointMake(leftWidth / 2, height / 2);
        _rightItemView.center = CGPointMake(width - rightWidth / 2, height / 2);
        
        
        UIView *titleView = nil;
        CGSize size = CGSizeZero;
        if (_titleView) {
            titleView = _titleView;
            size = _titleViewSize;
        } else if (_titleLabel) {
            titleView = _titleLabel;
            size = _titleSize;
        }
        
        if (titleView) {
            
            CGFloat margin = UIApplication.gkNavigationBarMargin;
            
            CGFloat x = (width - size.width) / 2;
            CGRect frame = CGRectMake(MAX(x, margin), (height - size.height) / 2, MIN(size.width, width - margin * 2), size.height);
            
            if (CGRectGetMinX(frame) < leftWidth || CGRectGetMaxX(frame) > width - rightWidth) {
                
                if(CGRectGetMinX(frame) < leftWidth){
                    frame.origin.x = leftWidth;
                }
                
                if (CGRectGetMaxX(frame) > width - rightWidth) {
                    frame.size.width = width - frame.origin.x - rightWidth;
                }
            }
            
            titleView.frame = frame;
        }
    }
}

// MARK: - Class Method

+ (UIButton*)itemWithImage:(UIImage*) image target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(image.renderingMode != UIImageRenderingModeAlwaysTemplate){
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    [btn setImage:image forState:UIControlStateNormal];
    if (target && action) {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [btn gkSetTintColor:UIColor.grayColor forState:UIControlStateDisabled];
    btn.frame = CGRectMake(0, 0, image.size.width + UIApplication.gkNavigationBarMargin * 2, UIApplication.gkNavigationBarHeight);
    
    return btn;
}

+ (UIButton*)itemWithTitle:(NSString*) title target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = UIFont.gkNavigationBarItemFont;
    [btn setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    if (target && action) {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    CGSize size = [title gkStringSizeWithFont:btn.titleLabel.font];
    btn.frame = CGRectMake(0, 0, size.width + UIApplication.gkNavigationBarMargin * 2, UIApplication.gkNavigationBarHeight);
    
    return btn;
}

@end
