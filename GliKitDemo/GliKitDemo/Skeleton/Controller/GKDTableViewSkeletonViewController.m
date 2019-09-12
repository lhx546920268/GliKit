//
//  GKDTableViewSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTableViewSkeletonViewController.h"
#import "GKDTableViewSkeletonCell.h"
#import <UIView+GKSkeleton.h>
#import "GKDTableViewSkeletonHeader.h"

@interface GKDTableViewSkeletonViewController ()

@property(nonatomic, strong) NSArray *datas;

@end

@implementation GKDTableViewSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"TableView";
    NSMutableArray *datas = [NSMutableArray array];
    for(NSInteger i = 0;i < 10;i ++){
        [datas addObject:@(i)];
    }
    
    self.datas = datas;
    [self initViews];
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    [self registerNib:GKDTableViewSkeletonCell.class];
    [self registerClassForHeaderFooterView:GKDTableViewSkeletonHeader.class];
    self.tableView.rowHeight = 80;
    
    [super initViews];
    
    [self.tableView gkShowSkeleton];
    
    [self performSelector:@selector(hideSkeleton) withObject:nil afterDelay:2.0];
}


- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSkeleton) object:nil];
}

- (void)hideSkeleton
{
    [self.tableView gkHideSkeletonWithAnimate:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GKDTableViewSkeletonHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:GKDTableViewSkeletonHeader.gkNameOfClass];
    
    header.titleLabel.text = @"这是第一个section header";
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    GKDTableViewSkeletonHeader *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:GKDTableViewSkeletonHeader.gkNameOfClass];
    
    footer.titleLabel.text = @"这是第一个section footer";
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDTableViewSkeletonCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDTableViewSkeletonCell.gkNameOfClass forIndexPath:indexPath];
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
