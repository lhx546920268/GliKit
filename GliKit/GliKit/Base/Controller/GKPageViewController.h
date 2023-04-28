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

///翻页容器相关扩展
@interface UIViewController (GKPage)

///在翻页容器中是否可见
@property(nonatomic, assign) BOOL visibleInPage;

@end

///翻页容器
@interface GKPageViewController : GKScrollViewController<GKTabMenuBarDelegate>

///顶部菜单 当 shouldUseMenuBar = NO，return nil
@property(nonatomic, readonly, nullable) GKTabMenuBar *menuBar;

///是否需要用菜单 menuBar default `YES`
@property(nonatomic, assign) BOOL shouldUseMenuBar;

///是否需要设置菜单 为 topView default `YES`
@property(nonatomic, assign) BOOL shouldSetMenuBarTopView;

///菜单栏高度 default `GKMenuBarHeight`
@property(nonatomic, assign) CGFloat menuBarHeight;

///当前页码
@property(nonatomic, readonly) NSInteger currentPage;

/**
 显示的viewControllers 调用时会自动创建，需要自己添加 viewController
 这里的Controller 如果是ScrollViewController 或者webViewController， 左右滑动时会关闭上下滑动
 @note 不要调用 removAllObjects 使用 removeAllViewContollers
 */
@property(nonatomic, readonly) NSMutableArray<UIViewController*> *pageViewControllers;

///移除所有viewController  reloadData 之前调用这个
- (void)removeAllViewContollers;

///刷新数据
- (void)reloadData;

///跳转到某一页 可动画
- (void)setPage:(NSUInteger) page animate:(BOOL) animate;

///获取对应下标的controller ，子类要重写
- (UIViewController*)viewControllerForIndex:(NSUInteger) index;

///页数量 默认是返回 menuBar.titles.count，如果 shouldUseMenuBar = NO,需要重写该方法
- (NSInteger)numberOfPage;

///滑动到某一页，setPage方法 不会触发这个
- (void)onScrollTopPage:(NSInteger) page bySliding:(BOOL) sliding;;

@end

NS_ASSUME_NONNULL_END

