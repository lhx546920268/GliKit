//
//  GKTableViewConfig.m
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKTableViewConfig.h"
#import "GKBaseDefines.h"

@implementation GKTableViewConfig

@dynamic viewController;

- (UITableView *)tableView
{
    return self.viewController.tableView;
}

///注册cell
- (void)registerNib:(Class)clazz
{
    [self.viewController registerNib:clazz];
}

- (void)registerClass:(Class) clazz
{
    [self.viewController registerClass:clazz];
}

- (void)registerNibForHeaderFooterView:(Class) clazz
{
    [self.viewController registerNibForHeaderFooterView:clazz];
}

- (void)registerClassForHeaderFooterView:(Class) clazz
{
    [self.viewController registerClassForHeaderFooterView:clazz];
}

// MARK: - UITableViewDelegate

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return GKTableViewMinHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return GKTableViewMinHeaderFooterHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GKThrowNotImplException
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKThrowNotImplException
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = self.viewController.separatorEdgeInsets;
}

@end
