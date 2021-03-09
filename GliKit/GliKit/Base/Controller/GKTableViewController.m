//
//  GKTableViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTableViewController.h"
#import "UITableView+GKUtils.h"
#import "UIView+GKEmptyView.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "GKBaseDefines.h"
#import "GKTableViewConfig.h"

@interface GKTableViewController ()

@end

@implementation GKTableViewController

@synthesize tableView = _tableView;

- (instancetype)initWithStyle:(UITableViewStyle) style
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        _style = style;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

// MARK: - Init

- (void)initViews
{
    [super initViews];
    [self initTableView];
    if(self.config){
        NSAssert([self.config isKindOfClass:GKTableViewConfig.class], @"%@.config 必须是GKTableViewConfig的子类", NSStringFromClass(self.class));
        [self.config config];
        _tableView.dataSource = self.config;
        _tableView.delegate = self.config;
    }else{
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    self.contentView = _tableView;
}

- (void)initTableView
{
    if(!_tableView){
        Class clazz = [self tableViewClass];
        NSAssert(![clazz isKindOfClass:[UITableView class]], @"tableViewClass 必须是UITableView 或者 其子类");
        _tableView = [[clazz alloc] initWithFrame:CGRectZero style:_style];
        _tableView.backgroundView = nil;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if(_style == UITableViewStyleGrouped){
            _tableView.backgroundColor = UIColor.gkGrayBackgroundColor;
        }
        _tableView.gkEmptyViewDelegate = self;
        _tableView.separatorInset = self.separatorEdgeInsets;
        
        self.scrollView = _tableView;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableView.separatorInset = self.separatorEdgeInsets;
}

// MARK: - Register Cell

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
    cell.separatorInset = self.separatorEdgeInsets;
}

// MARK: - 屏幕旋转

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_tableView reloadData];
}

@end
