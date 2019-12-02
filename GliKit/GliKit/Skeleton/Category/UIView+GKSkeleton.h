//
//  UIView+GKSkeleton.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKSkeletonLayer;

//显示骨架延迟回调
typedef void(^GKShowSkeletonCompletionHandler)(void);

//骨架状态
typedef NS_ENUM(NSInteger, GKSkeletonStatus){
    
    ///什么都没
    GKSkeletonStatusNone,
    
    ///准备要显示了
    GKSkeletonStatusWillShow,
    
    ///正在显示
    GKSkeletonStatusShowing,
    
    ///将要隐藏了
    GKSkeletonStatusWillHide,
};

///为视图创建骨架扩展
@interface UIView (GKSkeleton)

///是否需要添加为骨架图层 子视图用的
@property(nonatomic, assign) BOOL gkShouldBecomeSkeleton;

///骨架显示状态 根视图用 内部使用 不要直接设置这个值
@property(nonatomic, assign) GKSkeletonStatus gkSkeletonStatus;

///骨架图层
@property(nonatomic, strong, nullable) GKSkeletonLayer *gkSkeletonLayer;

///显示骨架
- (void)gkShowSkeleton;

///显示骨架 0.5s 延迟
- (void)gkShowSkeletonWithCompletion:(nullable GKShowSkeletonCompletionHandler) completion;

///显示骨架
- (void)gkShowSkeletonWithDuration:(NSTimeInterval) duration completion:(nullable GKShowSkeletonCompletionHandler) completion;

///隐藏骨架
- (void)gkHideSkeletonWithAnimate:(BOOL) animate;

///隐藏骨架
- (void)gkHideSkeletonWithAnimate:(BOOL) animate completion:(void(NS_NOESCAPE ^ __nullable)(BOOL finished)) completion;

///是否需要添加骨架图层 某些视图会自己处理 默认YES
- (BOOL)gkShouldAddSkeletonLayer;

@end

NS_ASSUME_NONNULL_END
