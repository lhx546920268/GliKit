//
//  GKNavigationInteractiveTransition.h
//  GliKit
//
//  Created by 罗海雄 on 2020/6/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///导航栏可交互的转场动画
@interface GKNavigationInteractiveTransition : UIPercentDrivenInteractiveTransition

///关联的手势
@property(nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@end

NS_ASSUME_NONNULL_END
