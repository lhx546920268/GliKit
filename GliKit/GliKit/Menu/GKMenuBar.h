//
//  GKMenuBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/10/21.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///默认高度
static const CGFloat GKMenuBarHeight = 40.0;

///菜单条样式
typedef NS_ENUM(NSInteger, GKMenuBarStyle)
{
    ///自动检测
    GKMenuBarStyleAutoDetect,
    
    ///按钮的宽度和标题宽度对应，多余的可滑动
    GKMenuBarStyleFit,
    
    ///按钮的宽度根据按钮数量和菜单宽度等分，不可滑动
    GKMenuBarStyleFill,
};

@class GKMenuBar, GKMenuBarItem;

///菜单条代理
@protocol GKMenuBarDelegate <NSObject>

@optional

///点击某个item
- (void)menuBar:(GKMenuBar*) menu didSelectItemAtIndex:(NSUInteger) index;

///取消选择某个按钮
- (void)menuBar:(GKMenuBar*) menu didDeselectItemAtIndex:(NSUInteger) index;

///点击高亮的按钮
- (void)menuBar:(GKMenuBar*) menu didSelectHighlightedItemAtIndex:(NSUInteger) index;

///是否可以点击某个按钮 default is 'YES'
- (BOOL)menuBar:(GKMenuBar*) menu shouldSelectItemAtIndex:(NSUInteger) index;

@end

///菜单条基类 不要直接使用这个 继承，或者使用 GKTabMenuBar
@interface GKMenuBar : UIView

///按钮容器
@property(nonatomic, readonly) UICollectionView *collectionView;

///内容间距 default `zero`
@property(nonatomic, assign) UIEdgeInsets contentInset;

///是否显示菜单顶部分割线
@property(nonatomic, assign) BOOL displayTopDivider;

///菜单底部分割线
@property(nonatomic, assign) BOOL displayBottomDivider;

// MARK: - 下划线

///按钮选中下划线颜色 只有 indicatorHeight > 0 才创建
@property(nonatomic, readonly) UIView *indicator;

///按钮选中下划线大小 default `{0, 2.0}`，宽度是小于0则表示填满，0表示和item内容宽度一样，其他值显示固定宽度
@property(nonatomic, assign) CGSize indicatorSize;

///下划线距离间距，default `0`
@property(nonatomic, assign) CGFloat indicatorPadding;

///按钮选中下划线颜色 default `themeColor`
@property(nonatomic, strong, null_resettable) UIColor *indicatorColor;

//MARK: - 按钮样式

///样式 默认自动检测 要计算完成才能确定 layoutSubviews
@property(nonatomic, assign) GKMenuBarStyle style;

///当前样式
@property(nonatomic, readonly) GKMenuBarStyle currentStyle;

///按钮间隔 只有 GKTabMenuBarStyleFit 生效 default `5.0`
@property(nonatomic, assign) CGFloat itemSpacing;

///按钮宽度延伸 left + right defautl `10.0`
@property(nonatomic, assign) CGFloat itemPadding;

///按钮间隔是否等分 default is `YES` GKTabMenuBarStyleFill 生效
@property(nonatomic,assign) BOOL shouldEqualItemSpacing;

///内容宽度
@property(nonatomic, readonly) CGFloat contentWidth;

//MARK: - 其他

///当前选中的菜单按钮下标 default `0`
@property(nonatomic, assign) NSUInteger selectedIndex;

///设置 selectedIndex 是否调用代理 default `NO`
@property(nonatomic, assign) BOOL callDelegateWhenSetSelectedIndex;

///计算完成回调 layoutSubviews 后
@property(nonatomic, copy, nullable) void(^measureCompletionHandler)(void);

///是否已经可以计算item
@property(nonatomic, readonly) BOOL measureEnabled;

///代理回调
@property(nonatomic, weak, nullable) id<GKMenuBarDelegate> delegate;

///按钮信息 设置此值会导致菜单重新加载数据
@property(nonatomic, copy, nullable) NSArray<GKMenuBarItem*> *items;

// MARK: - Init

///初始化
- (instancetype)initWithItems:(nullable NSArray<GKMenuBarItem*> *) items;
- (instancetype)initWithFrame:(CGRect)frame items:(nullable NSArray<GKMenuBarItem*> *) items;

// MARK: - 子类重写

///已经创建collectionView，将要addSubview
- (void)didInitCollectionView:(UICollectionView*) collectionView;

///子类计算 item大小，返回item总宽度
- (CGFloat)onMeasureItems;

///选中某个item
- (void)onSelectItemAtIndex:(NSUInteger) index oldIndex:(NSUInteger) oldIndex;

// MARK: - 设置

///设置选中的菜单按钮 可动画
- (void)setSelectedIndex:(NSUInteger) selectedIndex animated:(BOOL) flag;

/// 设置将要到某个item的偏移量比例
/// @param percent 比例 0 ~ 1.0
/// @param index 将要到的下标
- (void)setPercent:(float) percent forIndex:(NSUInteger) index;

///通过下标获取按钮
- (nullable __kindof UICollectionViewCell*)cellForIndex:(NSUInteger) index;

@end

NS_ASSUME_NONNULL_END
