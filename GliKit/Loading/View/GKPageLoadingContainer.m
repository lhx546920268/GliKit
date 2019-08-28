//
//  GKPageLoadingContainer.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
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
        _textLabel.textColor = [UIColor gkColorFromHex:@"aeaeae"];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"load_error_tip";
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        [_textLabel makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(0);
            make.top.equalTo(self.imageView.bottom).offset(25);
        }];
    }
    
    return self;
}

@end

@interface GKPageLoadingContainer()

///错误内容视图
@property(nonatomic, strong) GKPageErrorContentView *errorContentView;

///loading内容视图
@property(nonatomic, strong) GKPageLoadingContentView *loadingContentView;


@end

@implementation GKPageLoadingContainer

@synthesize status = _status;
@synthesize refreshHandler = _refreshHandler;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _loadingContentView = [GKPageLoadingContentView new];
        [self addSubview:_loadingContentView];
        
        [_loadingContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(newWindow && self.status == GKPageLoadingStatusLoading){
        [self startAnimating];
    }else{
        [self stopAnimating];
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
            [self startAnimating];
            self.errorContentView.hidden = YES;
            
            break;
        case GKPageLoadingStatusError :
            
            [self stopAnimating];
            self.loadingContentView.hidden = YES;
            [self showErrorView];
            break;
    }
}

- (void)startAnimating
{
    [self.loadingContentView.indicatorView startAnimating];
}

- (void)stopAnimating
{
    [self.loadingContentView.indicatorView stopAnimating];
}

///显示错误视图
- (void)showErrorView
{
    if(!self.errorContentView){
        self.errorContentView = [GKPageErrorContentView new];
        [self addSubview:self.errorContentView];
        
        [self.errorContentView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRefresh)]];
    }
    
    self.errorContentView.hidden = NO;
}

//MARK: action

//刷新
- (void)handleRefresh
{
    if(self.status == GKPageLoadingStatusError){
        !self.refreshHandler ?: self.refreshHandler();
    }
}

@end
