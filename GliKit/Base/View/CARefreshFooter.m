//
//  GKRefreshFooter.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKRefreshFooter.h"

@interface GKRefreshFooter()

///没有更多数据 线条
@property(nonatomic, strong) UIView *leftLine;
@property(nonatomic, strong) UIView *rightLine;

///加载中菊花
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation GKRefreshFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.shouldDisplayIndicator = YES;
        self.stateLabel.textColor = [UIColor gk_colorFromHex:@"CCCCCC"];
        self.stateLabel.font = [UIFont appFontWithSize:14];
        [self setTitle:@"no_datas".zegoLocalizedString forState:MJRefreshStateNoMoreData];
        [self setTitle:@"" forState:MJRefreshStateIdle];
        [self setTitle:@"loading".zegoLocalizedString forState:MJRefreshStateRefreshing];
    }
    
    return self;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView];
    }
    
    return _loadingView;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.loadingView.constraints.count) return;
    
    // 圈圈
    CGFloat loadingCenterX = self.mj_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.mj_textWith * 0.5 + self.labelLeftInset;
    }
    CGFloat loadingCenterY = self.mj_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
    
    if(self.leftLine){
        CGFloat x = (self.mj_w - self.stateLabel.mj_textWith) / 2;
        self.leftLine.frame = CGRectMake(15, (self.mj_h - 0.5) / 2, x - 15 - 5, 0.5);
        self.rightLine.frame = CGRectMake(x + self.stateLabel.mj_textWith  + 5, self.leftLine.mj_y, self.leftLine.mj_w, self.leftLine.mj_h);
    }
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    if(state == MJRefreshStateNoMoreData){
        
        [self initLines];
        self.leftLine.hidden = NO;
        self.rightLine.hidden = NO;
    }else{
        self.leftLine.hidden = YES;
        self.rightLine.hidden = YES;
    }
    
    // 根据状态做事情
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle || !self.shouldDisplayIndicator) {
        [self.loadingView stopAnimating];
    } else if (state == MJRefreshStateRefreshing) {
        [self.loadingView startAnimating];
    }
}

///初始化线条
- (void)initLines
{
    if(!self.leftLine){
        self.leftLine = [UIView new];
        self.leftLine.backgroundColor = self.stateLabel.textColor;
        [self addSubview:self.leftLine];
        
        self.rightLine = [UIView new];
        self.rightLine.backgroundColor = self.stateLabel.textColor;
        [self addSubview:self.rightLine];
    }
}

@end
