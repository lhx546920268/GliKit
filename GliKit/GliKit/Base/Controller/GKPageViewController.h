//
//  GKPageViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKScrollViewController.h"
#import "GKTabMenuBar.h"

NS_ASSUME_NONNULL_BEGIN

///翻页容器
@interface GKPageViewController : GKScrollViewController<GKTabMenuBarDelegate>

/**
 顶部菜单 当 shouldUseMenuBar = NO，return nil
 */
@property(nonatomic, readonly, nullable) GKTabMenuBar *menuBar;

/**
 是否需要用菜单 menuBar default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldUseMenuBar;

/**
 是否需要设置菜单 为 topView default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldSetMenuBarTopView;

/**
 菜单栏高度 default is GKMenuBarHeight
 */
@property(nonatomic, assign) CGFloat menuBarHeight;

/**
 当前页码
 */
@property(nonatomic, readonly) NSInteger currentPage;

/**
 显示的viewControllers 调用时会自动创建，需要自己添加 viewController
 这里的Controller 如果是ScrollViewController 或者webViewController， 左右滑动时会关闭上下滑动
 @note 不要调用 removAllObjects 使用 removeAllViewContollers
 */
@property(nonatomic, readonly) NSMutableArray<UIViewController*> *pageViewControllers;

/**
 移除所有viewController  reloadData 之前调用这个
 */
- (void)removeAllViewContollers;

/**
 刷新数据
 */
- (void)reloadData;

/**
 跳转到某一页
 
 @param page 页码
 @param animate 是否动画
 */
- (void)setPage:(NSUInteger) page animate:(BOOL) animate;

/**
 获取对应下标的controller ，子类要重写
 
 @param index 对应下标
 @return 对应下标的controller
 */
- (UIViewController*)viewControllerForIndex:(NSUInteger) index;

/**
 页数量 默认是返回 menuBar.titles.count，如果 shouldUseMenuBar = NO,需要重写该方法
 
 @return 页数量
 */
- (NSInteger)numberOfPage;

/**
 滑动到某一页，setPage 时不调用
 
 @param page 某一页
 */
- (void)onScrollTopPage:(NSInteger) page;

@end

NS_ASSUME_NONNULL_END

