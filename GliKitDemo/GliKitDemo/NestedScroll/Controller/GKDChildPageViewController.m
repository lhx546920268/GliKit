//
//  GKDChildPageViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDChildPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKDChildPageViewController ()


@end

@implementation GKDChildPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews
{
    [self registerClass:[UITableViewCell class]];
    self.tableView.gkNestedScrollEnabled = YES;
    [super initViews];
  //  self.refreshEnable = YES;
    self.loadMoreEnabled = YES;
    [self stopLoadMoreWithMore:YES];
}

- (void)onRefesh
{
    [super onRefesh];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)onLoadMore
{
    [super onLoadMore];
    [self performSelector:@selector(stopLoadMoreWithMore:) withObject:@(NO) afterDelay:2.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 130;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell gkNameOfClass] forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld个", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"click child");
}

@end
