//
//  UITextView+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (GKUtils)

/**
 添加默认的 inputAccessoryView

 @param title 标题
 @param target 点击确定方法回调，nil则使用默认的 关闭键盘
 @param action 点击确定方法回调，nil则使用默认的 关闭键盘
 */
- (void)gkAddDefaultInputAccessoryViewWithTitle:(nullable NSString*) title target:(id) target action:(SEL) action;
- (void)gkAddDefaultInputAccessoryViewWithTarget:(nullable id) target action:(SEL) action;
- (void)gkAddDefaultInputAccessoryViewWithTitle:(nullable NSString *)title;
- (void)gkAddDefaultInputAccessoryView;

@end

NS_ASSUME_NONNULL_END
