//
//  UIViewController+GKKeyboard.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///键盘相关扩展
@interface UIViewController (GKKeyboard)

///键盘是否隐藏
@property(nonatomic, readonly) BOOL keyboardHidden;

///键盘大小
@property(nonatomic, readonly) CGRect keyboardFrame;

///键盘动画时长
@property(nonatomic, readonly) NSTimeInterval keyboardAnimationDuration;

///添加键盘监听
- (void)addKeyboardNotification;

///移除键盘监听
- (void)removeKeyboardNotification;

///键盘高度改变
- (void)keyboardWillChangeFrame:(NSNotification*) notification NS_REQUIRES_SUPER;
- (void)keyboardDidChangeFrame:(NSNotification*) notification;

///键盘隐藏
- (void)keyboardWillHide:(NSNotification*) notification NS_REQUIRES_SUPER;

///键盘显示
- (void)keyboardWillShow:(NSNotification*) notification NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END

