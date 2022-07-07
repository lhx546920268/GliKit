//
//  GKTableViewConfig.h
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKScrollViewConfig.h"
#import "GKTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

///列表配置 主要用于 tableView delegate 和 dataSource 代码太多时，防止viewController代码臃肿
@interface GKTableViewConfig : GKScrollViewConfig<UITableViewDelegate, UITableViewDataSource>

///绑定的viewController
@property(nonatomic, weak, nullable, readonly) __kindof GKTableViewController *viewController;

///关联的tableView
@property(nonatomic, nullable, readonly) UITableView *tableView;

///注册cell
- (void)registerNib:(Class) clazz;
- (void)registerClass:(Class) clazz;

///注册header footer
- (void)registerNibForHeaderFooterView:(Class) clazz;
- (void)registerClassForHeaderFooterView:(Class) clazz;

@end

NS_ASSUME_NONNULL_END
