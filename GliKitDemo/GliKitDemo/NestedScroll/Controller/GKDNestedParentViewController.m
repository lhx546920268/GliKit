//
//  GKDNestedParentViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNestedParentViewController.h"
#import "GKDNestedTableViewCell.h"
#import "GKDNestedPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKDNestedPageCell : UITableViewCell

///要显示的viewController
@property(nonatomic, strong) UIViewController *viewController;

///父
@property(nonatomic, weak) UIViewController *parentViewController;

@end

@interface GKDNestedParentViewController ()

@property(nonatomic, strong) GKDNestedPageViewController *page;

@end

@implementation GKDNestedParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = [GKDNestedPageViewController new];
    
    [self initViews];
}

- (void)initViews
{
    [self registerNib:[GKDNestedTableViewCell class]];
    [self registerClassForHeaderFooterView:[UITableViewHeaderFooterView class]];
    [self registerClass:[GKDNestedPageCell class]];
    
    self.tableView.gkNestedParent = YES;
    self.tableView.gkNestedScrollEnabled = YES;
    [super initViews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0 :
            return 0;
        case 1 :
            return 3;
        case 2 :
            return 1;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     switch (indexPath.section) {
           case 0 :
               return 0;
           case 1 :
               return 45;
           case 2 :
               return tableView.gkHeight;
           default:
               break;
       }
       return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 50 : CGFLOAT_MIN;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[UITableViewHeaderFooterView gkNameOfClass]];
        
        header.textLabel.text = @"悬浮";
        
        return header;
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        GKDNestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[GKDNestedTableViewCell gkNameOfClass] forIndexPath:indexPath];
        
        [cell.btn setTitle:[NSString stringWithFormat:@"第%ld个按钮", indexPath.row] forState:UIControlStateNormal];
        cell.contentView.tag = indexPath.row + 1;
        
        return cell;
    }else{
        GKDNestedPageCell *cell = [tableView dequeueReusableCellWithIdentifier:[GKDNestedPageCell gkNameOfClass] forIndexPath:indexPath];
        cell.parentViewController = self;
        cell.viewController = self.page;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"click parent");
}


@end

@implementation GKDNestedPageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setViewController:(UIViewController *)viewController
{
    if(_viewController != viewController){
        if(_viewController){
            [_viewController removeFromParentViewController];
            [_viewController.view removeFromSuperview];
        }
        
        _viewController = viewController;
        [self.contentView addSubview:_viewController.view];
        [self.parentViewController addChildViewController:_viewController];
        
        [_viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
    }
}

@end
