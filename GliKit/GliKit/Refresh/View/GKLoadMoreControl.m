//
//  GKLoadMoreControl.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKLoadMoreControl.h"
#import "UIView+GKUtils.h"
#import "NSString+GKUtils.h"

/**
 UIScrollView 的内容大小
 */
static NSString *const GKDataControlContentSize = @"contentSize";

@interface GKLoadMoreControl()

///是否需要动画
@property(nonatomic, assign) BOOL shouldAnimate;

@end

@implementation GKLoadMoreControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super initWithScrollView:scrollView];
    if(self){
        
        [self setState:GKDataControlStateNoData];
    }
    
    return self;
}

- (void)initialization
{
    [super initialization];
    self.criticalPoint = 45;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    [self setTitle:@"加载更多" forState:GKDataControlStateNormal];
    [self setTitle:@"加载中..." forState:GKDataControlStateLoading];
    [self setTitle:@"松开即可加载" forState:GKDataControlStateReachCirticalPoint];
    [self setTitle:@"已到底部" forState:GKDataControlStateNoData];
    [self setTitle:@"加载失败，点击重新加载" forState:GKDataControlStateFail];
    self.autoLoadMore = YES;
}

- (void)setIsHorizontal:(BOOL)isHorizontal
{
    if(_isHorizontal != isHorizontal){
        _isHorizontal = isHorizontal;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //调整内容
    if(self.isHorizontal){
        CGFloat minWidth = self.criticalPoint;
        
        CGRect frame = self.frame;
        frame.size.height = self.scrollView.gkHeight;
        frame.size.width = MAX(minWidth, self.scrollView.contentOffset.x + self.scrollView.gkWidth - self.scrollView.contentSize.width);
        frame.origin.x = self.scrollView.contentSize.width;
        
        self.frame = frame;
    }else{
        CGFloat minHeight = self.criticalPoint;
        
        CGRect frame = self.frame;
        frame.size.width = self.scrollView.gkWidth;
        frame.size.height = MAX(minHeight, self.scrollView.contentOffset.y + self.scrollView.gkHeight - self.scrollView.contentSize.height);
        frame.origin.y = self.scrollView.contentSize.height;
        
        self.frame = frame;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(newSuperview){
        //添加 内容大小监听
        [newSuperview addObserver:self forKeyPath:GKDataControlContentSize options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeFromSuperview
{
    [self.superview removeObserver:self forKeyPath:GKDataControlContentSize];
    [super removeFromSuperview];
}

// MARK: - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:GKDataControlOffset]){
      
        [self onContentOffsetChange];
    }else if ([keyPath isEqualToString:GKDataControlContentSize]){
        
        [self setNeedsLayout];
    }
}

///contentOffset改变
- (void)onContentOffsetChange
{
    if(self.state == GKDataControlStateNoData
       || self.state == GKDataControlStateLoading
       || self.state == GKDataControlStateFail
       || self.hidden)
        return;
    
    if(!self.loadMoreEnableWhileZeroContent && CGSizeEqualToSize(self.scrollView.contentSize, CGSizeZero)){
        return;
    }
    
    CGFloat contentSize = self.isHorizontal ? self.scrollView.contentSize.width : self.scrollView.contentSize.height;
    CGFloat offset = self.isHorizontal ? self.scrollView.contentOffset.x : self.scrollView.contentOffset.y;
    CGFloat size = self.isHorizontal ? self.scrollView.gkWidth : self.scrollView.gkHeight;
    
    if(contentSize == 0 || offset < contentSize - size || contentSize < size)
        return;
    
    if(self.autoLoadMore){
        
        if(offset >= contentSize - size - self.criticalPoint){
            
            [self beginLoadMore:NO];
        }
    }else{
        
        if(offset >= contentSize - size){
            
            if(self.scrollView.dragging){
                if (offset == contentSize - size){
                    
                    [self setState:GKDataControlStateNormal];
                }else if (offset < contentSize - size + self.criticalPoint){
                    
                    [self setState:GKDataControlStatePulling];
                }else{
                    [self setState:GKDataControlStateReachCirticalPoint];
                }
            }else if(offset >= contentSize - size + self.criticalPoint){
                
                [self beginLoadMore:YES];
            }
        }
    }
    
    if(!self.animating){
        [self setNeedsLayout];
    }
}

// MARK: - Super Method

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self onContentOffsetChange];
}

- (void)startLoading
{
    [super startLoading];
    
    self.animating = NO;
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self beginLoadMore:NO];
    [self setNeedsLayout];
}

- (void)stopLoading
{
    [self.scrollView setContentInset:self.originalContentInset];
    [self setState:GKDataControlStateNormal];
    self.scrollView.userInteractionEnabled = YES;
}

/**
 开始加载更多
 */
- (void)beginLoadMore:(BOOL) animate
{
    if(self.animating)
        return;
    
    if(animate){
        self.animating = YES;
        [UIView animateWithDuration:0.25 animations:^(void){
            
            UIEdgeInsets inset = self.originalContentInset;
            if(self.isHorizontal){
                inset.right += self.criticalPoint;
            }else{
                inset.bottom += self.criticalPoint;
            }
            self.scrollView.contentInset = inset;
        }completion:^(BOOL finish){
            
            [self setState:GKDataControlStateLoading];
            self.animating = NO;
        }];
    }else{
        
        [self setState:GKDataControlStateLoading];
        UIEdgeInsets inset = self.originalContentInset;
        if(self.isHorizontal){
            inset.right += self.criticalPoint;
        }else{
            inset.bottom += self.criticalPoint;
        }
        
        self.scrollView.contentInset = inset;
        self.animating = NO;
    }
}

- (void)onStateChange:(GKDataControlState)state
{
    [super onStateChange:state];

    switch (state) {
        case GKDataControlStateLoading : {
            if(self.autoLoadMore || self.loadingDelay <= 0){
                [self onStartLoading];
            }else{
                [self performSelector:@selector(onStartLoading) withObject:nil afterDelay:self.loadingDelay];
            }
        }
            break;
        case GKDataControlStateNoData : {
            UIEdgeInsets inset = self.originalContentInset;
            if(self.isHorizontal){
                inset.left = self.scrollView.contentInset.left;
                if(self.shouldStayWhileNoData){
                    inset.right = self.criticalPoint;
                }
            }else{
                inset.top = self.scrollView.contentInset.top;
                if(self.shouldStayWhileNoData){
                    inset.bottom = self.criticalPoint;
                }
            }
            if(self.shouldAnimate){
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    self.scrollView.contentInset = inset;
                }];
            }else{
                self.scrollView.contentInset = inset;
            }
        }
            break;
        case GKDataControlStateFail : {
            UIEdgeInsets inset = self.originalContentInset;
            if(self.isHorizontal){
                inset.left = self.scrollView.contentInset.left;
                inset.right = self.criticalPoint;
            }else{
                inset.top = self.scrollView.contentInset.top;
                inset.bottom = self.criticalPoint;
            }
            if(self.shouldAnimate){
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    self.scrollView.contentInset = inset;
                }];
            }else{
                self.scrollView.contentInset = inset;
            }
        }
            break;
        default:
            break;
    }
}


- (void)noMoreInfo
{
    [self stopRefreshWithNoInfo];
}

- (void)stopRefreshWithNoInfo
{
    self.scrollView.userInteractionEnabled = YES;
    [self setState:GKDataControlStateNoData];
}

- (void)loadFail
{
    self.scrollView.userInteractionEnabled = YES;
    [self setState:GKDataControlStateFail];
}

// MARK: - Action

- (void)handleTap:(UITapGestureRecognizer*) tap
{
    if(self.state != GKDataControlStateLoading && self.state != GKDataControlStateNoData)    {
        [self setState:GKDataControlStateLoading];
    }
}

@end
