//
//  GKTableViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKScrollViewController.h"
#import "UITableView+GKEmptyView.h"
#import "UITableView+GKRowHeight.h"

NS_ASSUME_NONNULL_BEGIN

///section header footer 不显示时的高度 estimatedHeightForHeaderInSection 不能小于1 否则会ios9,10闪退
static const CGFloat GKTableViewMinHeaderFooterHeight = 0.00001;

///基础列表视图控制器
@interface GKTableViewController : GKScrollViewController<UITableViewDelegate, UITableViewDataSource>

///信息列表
@property(nonatomic, readonly) UITableView *tableView;

///列表风格
@property(nonatomic, assign) UITableViewStyle style;

///分割线位置 default `(0, 15.0, 0, 0)`
@property(nonatomic, assign) UIEdgeInsets separatorEdgeInsets;

///tableView类，必须是UITableView 或者其子类
@property(nonatomic, readonly) Class tableViewClass;

///通过列表样式初始化
- (instancetype)initWithStyle:(UITableViewStyle) style;

///注册cell
- (void)registerNib:(Class) clazz;
- (void)registerClass:(Class) clazz;

///注册header footer
- (void)registerNibForHeaderFooterView:(Class) clazz;
- (void)registerClassForHeaderFooterView:(Class) clazz;

///需要调用super
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END

