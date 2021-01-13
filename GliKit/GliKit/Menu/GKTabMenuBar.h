//
//  GKTabMenuBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKMenuBar.h"
#import "GKTabMenuBarItem.h"

NS_ASSUME_NONNULL_BEGIN


@class GKTabMenuBar;

///条形菜单代理
@protocol GKTabMenuBarDelegate <GKMenuBarDelegate>

@optional

///要显示自定义视图了 要自己调整位置
- (void)menuBar:(GKTabMenuBar *)menu willDisplayCustomView:(UIView*) customView atIndex:(NSUInteger)index;

@end

///条形菜单 当菜单按钮数量过多时，可滑动查看更多的按钮
@interface GKTabMenuBar : GKMenuBar

//MARK: - 按钮样式

///菜单按钮字体颜色
@property(nonatomic, strong, null_resettable) UIColor *normalTextColor;

///菜单按钮字体
@property(nonatomic, strong, null_resettable) UIFont *normalFont;

///菜单按钮 选中颜色
@property(nonatomic, strong, null_resettable) UIColor *selectedTextColor;

///菜单按钮 选中字体 nil的时候使用 normalFont default `nil`
@property(nonatomic, strong, null_resettable) UIFont *selectedFont;

///是否显示分隔符 只有 GKTabMenuBarStyleFit 生效 default `YES`
@property(nonatomic, assign) BOOL displayItemDidvider;

//MARK: - 其他

///菜单按钮标题 设置此值会导致菜单重新加载数据
@property(nonatomic, copy, nullable) NSArray<NSString*> *titles;

///按钮信息 设置此值会导致菜单重新加载数据
@property(nonatomic, copy, nullable) NSArray<GKTabMenuBarItem*> *items;

///代理回调
@property(nonatomic, weak, nullable) id<GKTabMenuBarDelegate> delegate;

//MARK: - Init

///初始化
- (instancetype)initWithTitles:(nullable NSArray<NSString*> *) titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(nullable NSArray<NSString*> *) titles;

//MARK: - 设置

///设置按钮边缘数字 大于99会显示99+，小于等于0则隐藏
- (void)setBadgeValue:(nullable NSString*) badgeValue forIndex:(NSUInteger) index;

///改变按钮标题
- (void)setTitle:(nullable NSString*) title forIndex:(NSUInteger) index;

///改变按钮图标
- (void)setIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;

///改变选中按钮图标
- (void)setSelectedIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;

@end

NS_ASSUME_NONNULL_END

