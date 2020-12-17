//
//  GKSwipeCell.h
//  GliKit
//
//  Created by 罗海雄 on 2020/12/10.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///滑动方向
typedef NS_OPTIONS(NSInteger, GKSwipeDirection) {
    
    ///没
    GKSwipeDirectionNone,
    
    ///向左
    GKSwipeDirectionLeft = 1 << 0,
    
    ///向右
    GKSwipeDirectionRight = 1 << 1,
};

@protocol GKSwipeCellDelegate;

@protocol GKSwipeCell <NSObject>

///可以滑动的方向
@property(nonatomic, assign) GKSwipeDirection swipeDirection;

///当前方向
@property(nonatomic, readonly) GKSwipeDirection currentDirection;

///代理
@property(nonatomic, weak) id<GKSwipeCellDelegate> delegate;

///切换按钮状态
- (void)setSwipeShow:(BOOL) show direction:(GKSwipeDirection) direction animated:(BOOL) animated;

@end

///代理
@protocol GKSwipeCellDelegate <NSObject>

///获取按钮
- (NSArray<UIView*>*)swipeCell:(UIView<GKSwipeCell>*) cell swipeButtonsForDirection:(GKSwipeDirection) direction;

@end

///侧滑帮助类
@interface GKSwipeCellHelper : NSObject

///当前方向
@property(nonatomic, readonly) GKSwipeDirection currentDirection;

+ (instancetype)helperWithCell:(UIView<GKSwipeCell>*) cell;

- (void)setSwipeDirection:(GKSwipeDirection) swipeDirection;

- (void)setSwipeShow:(BOOL)show direction:(GKSwipeDirection)direction animated:(BOOL)animated;

- (void)willMoveToSuperview:(nullable UIView *)newSuperview;
- (void)willMoveToWindow:(nullable UIWindow *)newWindow;

@end

NS_ASSUME_NONNULL_END
