//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import <GKAppUtils.h>
#import <NSObject+GKUtils.h>
#import "GKDPhotosViewController.h"
#import "GKDSkeletonViewController.h"
#import "GKDTransitionViewController.h"
#import "GKDNestedParentViewController.h"
#import "GKDRowModel.h"
#import "GKDEmptyViewController.h"
#import "GKDProgressViewController.h"

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;


@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = GKAppUtils.appName;
    
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:GKDPhotosViewController.class],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:GKDSkeletonViewController.class],
                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:GKDTransitionViewController.class],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:GKDNestedParentViewController.class],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:GKDEmptyViewController.class],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:GKDProgressViewController.class],
                   ];
    
    [self initViews];
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    [self registerClass:UITableViewCell.class];
    [super initViews];
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.gkNameOfClass forIndexPath:indexPath];
    
    cell.textLabel.text = self.datas[indexPath.row].title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = UIColor.redColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GKDRowModel *model = self.datas[indexPath.row];
    [self.class gkPushViewController:model.clazz.new];
}

@end
