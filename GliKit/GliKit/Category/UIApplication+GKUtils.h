//
//  UIApplication+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/12/10.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (GKUtils)

/**
 弹窗 窗口
 */
@property(nonatomic, strong, nullable) UIWindow *dialogWindow;

/**
 创建弹窗 如果为空的时候
 */
- (void)loadDialogWindowIfNeeded;

/**
 当没有弹窗的时候 移除窗口
 */
- (void)removeDialogWindowIfNeeded;

@end

NS_ASSUME_NONNULL_END
