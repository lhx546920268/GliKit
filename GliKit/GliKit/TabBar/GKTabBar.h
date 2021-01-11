//
//  GKTabBar.h
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKTabBar, GKTabBarButton;

///选项卡代理
@protocol GKTabBarDelegate <NSObject>

///选中第几个
- (void)tabBar:(GKTabBar*) tabBar didClickAtIndex:(NSInteger) index;

@optional

///是否可以下第几个 default `YES`
- (BOOL)tabBar:(GKTabBar*) tabBar clickEnabledAtIndex:(NSInteger) index;

@end

///选项卡
@interface GKTabBar : UIView

///选项卡按钮
@property(nonatomic, copy, nullable) NSArray<GKTabBarButton*> *buttons;

///背景视图 default `nil` ,如果设置，大小会调节到选项卡的大小
@property(nonatomic, strong, nullable) UIView *backgroundView;

///设置选中 default `NSNotFound`
@property(nonatomic, assign) NSUInteger selectedIndex;

///选中按钮的背景颜色 default `nil`
@property(nonatomic, strong, nullable) UIColor *selectedButtonBackgroundColor;

///分割线
@property(nonatomic, readonly) UIView *separator;

///代理
@property(nonatomic, weak, nullable) id<GKTabBarDelegate> delegate;

///初始化
- (instancetype)initWithButtons:(nullable NSArray<GKTabBarButton*>*) buttons;

///设置角标值 @“”显示红点 nil隐藏
- (void)setBadgeValue:(nullable NSString*) badgeValue forIndex:(NSInteger) index;

@end

NS_ASSUME_NONNULL_END
