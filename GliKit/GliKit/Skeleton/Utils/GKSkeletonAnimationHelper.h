//
//  GKSkeletonAnimationHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///动画完成回调
typedef void(^GKSkeletonAnimationCompletion)(void);

///骨架动画帮助类
@interface GKSkeletonAnimationHelper : NSObject<CAAnimationDelegate>

///动画完成回调
@property(nonatomic, copy, nullable) GKSkeletonAnimationCompletion completion;

///执行透明度渐变动画
- (void)executeOpacityAnimationForLayer:(CALayer*) layer completion:(nullable GKSkeletonAnimationCompletion) completion;

@end

NS_ASSUME_NONNULL_END

