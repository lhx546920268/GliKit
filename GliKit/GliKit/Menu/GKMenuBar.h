//
//  GKMenuBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKMenuBarItem.h"
#import "GKMenuBarProps.h"

NS_ASSUME_NONNULL_BEGIN

///默认高度
static const CGFloat GKMenuBarHeight = 40.0;

///GKMenuBar 样式
typedef NS_ENUM(NSInteger, GKMenuBarStyle)
{
    ///自动检测
    GKMenuBarStyleAutoDetect,
    
    ///按钮的宽度和标题宽度对应，多余的可滑动
    GKMenuBarStyleFit,
    
    ///按钮的宽度根据按钮数量和菜单宽度等分，不可滑动
    GKMenuBarStyleFill,
};

@class GKMenuBar, GKMenuBarCell;

/**
 条形菜单代理
 */
@protocol GKMenuBarDelegate <NSObject>

///点击某个item
- (void)menuBar:(GKMenuBar*) menu didSelectItemAtIndex:(NSUInteger) index;

@optional

///取消选择某个按钮
- (void)menuBar:(GKMenuBar *)menu didDeselectItemAtIndex:(NSUInteger)index;

///点击高亮的按钮
- (void)menuBar:(GKMenuBar*) menu didSelectHighlightedItemAtIndex:(NSUInteger) index;

///是否可以点击某个按钮 default is 'YES'
- (BOOL)menuBar:(GKMenuBar*) menu shouldSelectItemAtIndex:(NSUInteger) index;

///要显示自定义视图了 要自己调整位置
- (void)menuBar:(GKMenuBar *)menu willDisplayCustomView:(UIView*) customView atIndex:(NSUInteger)index;

@end

/**
 条形菜单 当菜单按钮数量过多时，可滑动查看更多的按钮
 */
@interface GKMenuBar : UIView

//MARK: - 按钮样式

/**
 样式 默认自动检测 要计算完成才能确定 layoutSubviews
 */
@property(nonatomic, assign) GKMenuBarStyle style;

/**
 菜单属性
 */
@property(nonatomic, strong, null_resettable) GKMenuBarProps *props;

/**
 获取菜单宽度 ，根据当前标题、字体和间隔来
 */
@property(nonatomic, readonly) CGFloat menuBarWidth;

/**
 按钮选中下划线颜色 只有 props.indicatorHeight > 0 才创建
 */
@property(nonatomic, readonly) UIView *indicator;

//MARK: - 其他

/**
 当前选中的菜单按钮下标 default is '0'
 */
@property(nonatomic, assign) NSUInteger selectedIndex;

/**
 设置 selectedIndex 是否调用代理 default is 'NO'
 */
@property(nonatomic, assign) BOOL callDelegateWhenSetSelectedIndex;

/**
 计算完成回调 layoutSubviews 后
 */
@property(nonatomic, copy, nullable) void(^measureCompletionHandler)(void);

/**
 菜单按钮标题 设置此值会导致菜单重新加载数据
 */
@property(nonatomic, copy, nullable) NSArray<NSString*> *titles;

/**
 按钮信息 设置此值会导致菜单重新加载数据
 */
@property(nonatomic, copy, nullable) NSArray<GKMenuBarItem*> *items;

/**
 代理回调
 */
@property(nonatomic, weak, nullable) id<GKMenuBarDelegate> delegate;

//MARK: - Init

/**
 构造方法
 *@param titles 菜单按钮标题
 *@return 一个实例
 */
- (instancetype)initWithTitles:(nullable NSArray<NSString*> *) titles;

/**
 构造方法
 *@param items 按钮信息
 *@return 一个实例
 */
- (instancetype)initWithItems:(nullable NSArray<GKMenuBarItem*> *) items;

/**
 构造方法
 *@param frame 位置大小
 *@param titles 菜单按钮标题
 *@return 一个实例
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(nullable NSArray<NSString*> *) titles;

/**
 构造方法
 *@param frame 位置大小
 *@param items 按钮信息
 *@return 一个实例
 */
- (instancetype)initWithFrame:(CGRect)frame items:(nullable NSArray<GKMenuBarItem*> *) items;

//MARK: - 设置

/**设置选中的菜单按钮
 *@param selectedIndex 菜单按钮下标
 *@param flag 是否动画
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL) flag;

/**设置按钮边缘数字
 *@param badgeValue 边缘数字，大于99会显示99+，小于等于0则隐藏
 *@param index 按钮下标
 */
- (void)setBadgeValue:(nullable NSString*) badgeValue forIndex:(NSUInteger) index;

/**改变按钮标题
 *@param title 按钮标题
 *@param index 按钮下标
 */
- (void)setTitle:(nullable NSString*) title forIndex:(NSUInteger) index;

/**改变按钮图标
 *@param icon 按钮图标
 *@param index 按钮下标
 */
- (void)setIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;

/**改变选中按钮图标
 *@param icon 按钮图标
 *@param index 按钮下标
 */
- (void)setSelectedIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;

/**
 设置将要到某个item的偏移量比例
 
 @param percent 比例 0 ~ 1.0
 @param index 将要到的下标
 */
- (void)setPercent:(float) percent forIndex:(NSUInteger) index;

@end

NS_ASSUME_NONNULL_END

