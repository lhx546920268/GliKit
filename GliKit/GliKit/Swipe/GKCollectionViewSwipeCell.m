//
//  GKCollectionViewSwipeCell.m
//  GliKit
//
//  Created by 罗海雄 on 2020/12/10.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKCollectionViewSwipeCell.h"

@interface GKCollectionViewSwipeCell()

///侧滑帮助类
@property(nonatomic, strong) GKSwipeCellHelper *swipeCellHelper;

@end

@implementation GKCollectionViewSwipeCell

@synthesize swipeDirection = _swipeDirection;
@synthesize delegate;

- (void)setSwipeDirection:(GKSwipeDirection)swipeDirection
{
    if(_swipeDirection != swipeDirection){
        _swipeDirection = swipeDirection;
        if(!self.swipeCellHelper){
            self.swipeCellHelper = [GKSwipeCellHelper helperWithCell:self];
        }
        [self.swipeCellHelper setSwipeDirection:_swipeDirection];
    }
}

- (GKSwipeDirection)currentDirection
{
    return _swipeCellHelper.currentDirection;
}

- (void)setSwipeShow:(BOOL)show direction:(GKSwipeDirection)direction animated:(BOOL)animated
{
    [_swipeCellHelper setSwipeShow:show direction:direction animated:animated];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [_swipeCellHelper willMoveToSuperview:newSuperview];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    [_swipeCellHelper willMoveToWindow:newWindow];
}

@end
