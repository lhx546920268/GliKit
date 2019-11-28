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
#import <objc/runtime.h>
#import "GKDWebViewController.h"
#import <GKRouter.h>

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = GKAppUtils.appName;
    
    [GKRouter.sharedRouter registerName:@"photo" forClass:GKDPhotosViewController.class];
    
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:GKDPhotosViewController.class],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:GKDSkeletonViewController.class],
                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:GKDTransitionViewController.class],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:GKDNestedParentViewController.class],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:GKDEmptyViewController.class],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:GKDProgressViewController.class],
                   [GKDRowModel modelWithTitle:@"Web" clazz:GKDWebViewController.class],
                   ];
    [self initViews];
    
    if (@available(iOS 10.0, *)) {
        [NSThread detachNewThreadWithBlock:^{
            [self buyCount];
        }];
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 10.0, *)) {
        [NSThread detachNewThreadWithBlock:^{
            [self test];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)buyCount
{
    @synchronized (@"你") {
        [NSThread sleepForTimeInterval:3];
        NSLog(@"buyCount after 3 seconds");
    }
}

- (void)test
{
    @synchronized (@"我") {
        NSLog(@"test");
    }
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
    [GKRouter.sharedRouter pushApp:NSStringFromClass(model.clazz)];
}

@end
