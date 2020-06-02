//
//  GKBaseNavigationController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///基础导航控制视图
@interface GKBaseNavigationController : UINavigationController

///是否是手势交互返回
@property(nonatomic, readonly) BOOL isInteractivePop;

///是否使用自定义的转场动画 default NO
@property(nonatomic, assign) BOOL shouldUseCustomTransition;

///自定义转场动画时长 default 0.25
@property(nonatomic, assign) NSTimeInterval customTransitionDuration;

///自定义的滑动返回手势
@property(nonatomic, readonly) UIScreenEdgePanGestureRecognizer *customInteractivePopGestureRecognizer;

///pop 或者 push 完成回调，执行后会 变成nil
@property(nonatomic, copy) void(^transitionCompletion)(void);

@end

