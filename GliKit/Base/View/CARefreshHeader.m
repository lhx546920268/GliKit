//
//  GKRefreshHeader.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKRefreshHeader.h"
#import "GKPageLoadingContainer.h"
#import <SDAnimatedImage.h>
#import <SDAnimatedImageView.h>

@interface GKRefreshHeader()

///gif动画
@property(nonatomic, strong) SDAnimatedImageView *gifImageView;

///gif
@property(nonatomic, strong) SDAnimatedImage *gifImage;
@property(nonatomic, strong) UIImage *image;

@end

@implementation GKRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
       
        self.stateLabel.hidden = YES;
        self.lastUpdatedTimeLabel.hidden = YES;
        self.automaticallyChangeAlpha = YES;
        self.mj_h = 60;
        
        self.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"loading" ofType:@"gif"]];
        _gifImageView = [SDAnimatedImageView new];
        _gifImageView.image = self.image;
        _gifImageView.shouldCustomLoopCount = YES;
        _gifImageView.animationRepeatCount = NSNotFound;
        _gifImageView.bounds = CGRectMake(0, 0, 80, 40);
        [self addSubview:_gifImageView];
        
        [_gifImageView stopAnimating];
    }

    return self;
}

- (SDAnimatedImage *)gifImage
{
    if(!_gifImage){
        _gifImage = [[SDAnimatedImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"loading" ofType:@"gif"]];
    }
    return _gifImage;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.gifImageView.center = CGPointMake(self.mj_w / 2.0, self.mj_h / 2.0);
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState

    // 根据状态做事情
    if (state == MJRefreshStateRefreshing) {
        self.gifImageView.image = self.gifImage;
    } else {
        self.gifImageView.image = self.image;
    }
}

@end
