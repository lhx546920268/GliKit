//
//  GKNavigationBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///导航栏
@interface GKNavigationBar : UIView

///阴影
@property(nonatomic, readonly) UIView *shadowView;

///背景
@property(nonatomic, readonly) UIView *backgroundView;

///左边item 要设置大小
@property(nonatomic, strong, nullable) UIView *leftItemView;
@property(nonatomic, assign) BOOL leftItemEnabled;

///右边item 要设置大小
@property(nonatomic, strong, nullable) UIView *rightItemView;
@property(nonatomic, assign) BOOL rightItemEnabled;

///中间的
@property(nonatomic, strong, nullable) UIView *titleView;

///标题
@property(nonatomic, copy, nullable) NSString *title;

///标题
@property(nonatomic, readonly) UILabel *titleLabel;

///设置导航栏左边按钮
- (UIButton*)setLeftItemWithTitle:(NSString*) title target:(nullable id) target action:(nullable SEL) action;
- (UIButton*)setLeftItemWithImage:(UIImage*) image target:(nullable id) target action:(nullable SEL) action;

///设置导航栏右边按钮
- (UIButton*)setRightItemWithTitle:(NSString*) title target:(nullable id) target action:(nullable SEL) action;
- (UIButton*)setRightItemWithImage:(UIImage*) image target:(nullable id) target action:(nullable SEL) action;

@end

NS_ASSUME_NONNULL_END
