//
//  GKPageLoadingContainer.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKPageLoadingContainer.h"
#import "UIColor+GKUtils.h"
#import "GKBaseDefines.h"

///页面加载内容视图
@interface GKPageLoadingContentView : UIView

///loading
@property(nonatomic, readonly) UIActivityIndicatorView *indicatorView;

///加载出错提示文字
@property(nonatomic, readonly) UILabel *textLabel;

@end

@implementation GKPageLoadingContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicatorView];
        
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(0);
            make.top.greaterThanOrEqualTo(0);
            make.bottom.lessThanOrEqualTo(0);
        }];
        
        _textLabel = [UILabel new];
        _textLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_textLabel];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.indicatorView.trailing).offset(5);
            make.trailing.top.bottom.equalTo(0);
        }];
    }
    
    return self;
}


@end

///页面加载错误视图
@interface GKPageErrorContentView : UIView

///图标
@property(nonatomic, readonly) UIImageView *imageView;

///加载出错提示文字
@property(nonatomic, readonly) UILabel *textLabel;

@end

@implementation GKPageErrorContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"network_error_icon"];
        [self addSubview:_imageView];
        
        [_imageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(0);
        }];
        
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor gk_colorFromHex:@"aeaeae"];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"load_error_tip";
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        [_textLabel makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(0);
            make.top.equalTo(self.imageView.bottom).offset(25);
        }];
    }
    
    return self;
}

@end

@interface GKPageLoadingContainer()

///错误内容视图
@property(nonatomic, strong) UIView *errorContentView;

///加载出错的 图标
@property(nonatomic, readonly) UIImageView *errorImageView;

///加载出错提示文字
@property(nonatomic, readonly) UILabel *textLabel;

///刷新按钮
@property(nonatomic, readonly) UIButton *refreshButton;

///logo
@property(nonatomic, strong) UIImageView *logoImageView;

///loading内容视图
@property(nonatomic, strong) UIView *loadingContentView;

///动画图片
@property(nonatomic, readonly) SDAnimatedImageView *animatedimageView;

@end

@implementation GKPageLoadingContainer

@synthesize status = _status;
@synthesize refreshHandler = _refreshHandler;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _loadingContentView = [UIView new];
        [self addSubview:_loadingContentView];
        
        [_loadingContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
        
        _logoImageView = [UIImageView new];
        [_loadingContentView addSubview:_logoImageView];
        
        [_logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(self.loadingContentView);
        }];
        
        _animatedimageView = [SDAnimatedImageView new];
        _animatedimageView.image = [[SDAnimatedImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"loading" ofType:@"gif"]];
        _animatedimageView.shouldCustomLoopCount = YES;
        _animatedimageView.animationRepeatCount = NSNotFound;
        [self.loadingContentView addSubview:_animatedimageView];
        
        [_animatedimageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(self.loadingContentView);
            make.size.equalTo(CGSizeMake(80, 40));
            make.top.equalTo(self.logoImageView.mas_bottom);
        }];
    }
    
    return self;
}

- (void)setLogo:(UIImage *)logo
{
    if(_logo != logo){
        _logo = logo;
        self.logoImageView.image = _logo;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(newWindow && self.status == GKPageLoadingStatusLoading){
        [_animatedimageView startAnimating];
    }else{
        [_animatedimageView stopAnimating];
    }
}

- (void)setStatus:(GKPageLoadingStatus)status
{
    if(_status != status){
        _status = status;
        [self statusDidChange];
    }
}

///状态改变
- (void)statusDidChange
{
    switch (self.status) {
        case GKPageLoadingStatusLoading :
            self.loadingContentView.hidden = NO;
            [self.animatedimageView startAnimating];
            self.errorContentView.hidden = YES;
            
            break;
        case GKPageLoadingStatusError :
            
            [self.animatedimageView stopAnimating];
            self.loadingContentView.hidden = YES;
            [self showErrorView];
            break;
    }
}

///显示错误视图
- (void)showErrorView
{
    if(!self.errorContentView){
        UIView *contentView = [UIView new];
        [self addSubview:contentView];
        
        [contentView makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
        
        self.errorContentView = contentView;
        
        _errorImageView = [UIImageView new];
        _errorImageView.image = [UIImage imageNamed:@"ordermng_icon_empty"];
        [contentView addSubview:_errorImageView];
        
        [_errorImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(contentView);
            make.top.equalTo(contentView);
        }];
        
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor gk_colorFromHex:@"aeaeae"];
        _textLabel.font = [UIFont appFontWithSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"load_error_tip".zegoLocalizedString;
        _textLabel.numberOfLines = 0;
        [contentView addSubview:_textLabel];
        
        [_textLabel makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(contentView);
            make.top.equalTo(self.errorImageView.mas_bottom).offset(25);
        }];
        
        
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:@"refresh".zegoLocalizedString forState:UIControlStateNormal];
        [_refreshButton setTitleColor:UIColor.appBlackTextColor forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventTouchUpInside];
        _refreshButton.layer.cornerRadius = 15;
        _refreshButton.layer.borderWidth = 0.5;
        _refreshButton.layer.borderColor = [UIColor gk_colorFromHex:@"cccccc"].CGColor;
        _refreshButton.titleLabel.font = [UIFont appFontWithSize:14];
        [contentView addSubview:_refreshButton];
        
        [_refreshButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(contentView);
            make.size.equalTo(CGSizeMake(100, 30));
            make.bottom.equalTo(contentView);
            make.top.equalTo(self.textLabel.mas_bottom).offset(50);
        }];
    }
    
    self.errorContentView.hidden = NO;
}

#pragma mark action

//刷新
- (void)handleRefresh
{
    !self.refreshHandler ?: self.refreshHandler();
}

@end
