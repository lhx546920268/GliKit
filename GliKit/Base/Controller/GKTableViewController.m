//
//  GKTableViewController.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKTableViewController.h"
#import "UITableView+GKUtils.h"
#import "UIView+GKEmptyView.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"

@interface GKTableViewController ()

@end

@implementation GKTableViewController

@synthesize tableView = _tableView;

- (id)initWithStyle:(UITableViewStyle) style
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        _style = style;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _separatorEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0, 0);
}

- (UITableView*)tableView
{
    [self initTableView];
    return _tableView;
}

//MARK: public method

- (void)initViews
{
    [super initViews];
    [self initTableView];
    self.contentView = _tableView;
}

- (void)initTableView
{
    if(!_tableView){
        Class clazz = [self tableViewClass];
        NSAssert(![clazz isKindOfClass:[UITableView class]], @"tableViewClass 必须是UITableView 或者 其子类");
        _tableView = [[clazz alloc] initWithFrame:CGRectZero style:_style];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if(_style == UITableViewStyleGrouped){
            _tableView.backgroundColor = UIColor.gkGrayBackgroundColor;
        }
        _tableView.gkEmptyViewDelegate = self;
        
        [_tableView setSeparatorInset:self.separatorEdgeInsets];
        
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]){
            [_tableView setLayoutMargins:self.separatorEdgeInsets];
        }
        
        self.scrollView = _tableView;
    }
}

///注册cell
- (void)registerNib:(Class)clazz
{
    [self.tableView registerNib:clazz];
}

- (void)registerClass:(Class) clazz
{
    [self.tableView registerClass:clazz];
}

- (void)registerNibForHeaderFooterView:(Class) clazz
{
    [self.tableView registerNibForHeaderFooterView:clazz];
}

- (void)registerClassForHeaderFooterView:(Class) clazz
{
    [self.tableView registerClassForHeaderFooterView:clazz];
}

- (Class)tableViewClass
{
    return [UITableView class];
}

- (void)reloadListData
{
    if(self.isInit){
        [self.tableView reloadData];
    }
}

//MARK:- tableView 代理

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
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:self.separatorEdgeInsets];
    
    if([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:self.separatorEdgeInsets];
    }
    
    [tableView gk_setRowHeight:@(cell.gkHeight) forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [tableView gk_setHeaderHeight:@(view.gkHeight) forSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    [tableView gk_setFooterHeight:@(view.gkHeight) forSection:section];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(_tableView){
        [_tableView setSeparatorInset:self.separatorEdgeInsets];
        
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]){
            [_tableView setLayoutMargins:self.separatorEdgeInsets];
        }
    }
}

//MARK:- 屏幕旋转

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_tableView reloadData];
}

@end
