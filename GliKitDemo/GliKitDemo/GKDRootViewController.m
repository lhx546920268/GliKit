//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GKAppUtils.h>
#import <GKTableViewSwipeCell.h>
#import <GKObservable.h>

@interface DemoObservable : GKObservable

///x
@property(nonatomic, assign) NSInteger intValue;

///x
@property(nonatomic, assign) NSInteger integerValue;

///x
@property(nonatomic, copy) NSString *stringValue;

@end

@implementation DemoObservable


@end

@interface GKDRootListCell : GKTableViewSwipeCell

@end

@implementation GKDRootListCell

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

///x
@property(nonatomic, strong) DemoObservable *demo;

@end

@implementation GKDRootViewController

- (void)dealloc
{
    NSLog(@"GKDRootViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    self.navigationItem.title = GKAppUtils.appName;
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"GKDPhotosViewController"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"GKDSkeletonViewController"],
                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:@"GKDTransitionViewController"],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"GKDNestedParentViewController"],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   ];

    [self initViews];

    [self gkSetLeftItemWithTitle:@"左边" action:nil];
    
    __block UIBackgroundTaskIdentifier identifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:identifier];
    }];
    
    NSLog(@"这个一个后台任务");
    
    [UIApplication.sharedApplication endBackgroundTask:identifier];
    
    self.demo = [DemoObservable new];
    [self.demo addObserver:self callback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
        NSLog(@"%@, %d, %@", keyPath, [newValue intValue], oldValue);
    } forKeyPath:@"intValue"];
    
    [self.demo addObserver:self manualCallback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
        NSLog(@"manualCallback %@, %d, %@", keyPath, [newValue intValue], oldValue);
    } forKeyPath:@"integerValue"];
    
    NSLog(@"%ld, %ld, %ld, %ld", GKTestOptionsOne, GKTestOptionsTwo, GKTestOptionsThree, GKTestOptionsFour);
    
    myStaticTest = @"xx";
    NSLog(@"%x", &myStaticTest);
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    [self registerClass:GKDRootListCell.class];
    [super initViews];
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDRootListCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDRootListCell.gkNameOfClass forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.textLabel.text = self.datas[indexPath.row % self.datas.count].title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = UIColor.redColor;
    cell.swipeDirection = GKSwipeDirectionLeft | GKSwipeDirectionRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    self.demo.intValue = indexPath.row;
    self.demo.integerValue = indexPath.row;
    if(indexPath.row == 5){
        [self.demo flushManualCallbackForObserver:self];
    }
    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
    [GKRouter.sharedRouter pushApp:model.className];
}

- (NSArray<UIView *> *)swipeCell:(UIView<GKSwipeCell> *)cell swipeButtonsForDirection:(GKSwipeDirection)direction
{
    UIButton *deleteBtn = [UIButton new];
    deleteBtn.backgroundColor = UIColor.redColor;
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    deleteBtn.bounds = CGRectMake(0, 0, 100, 44);
    
    UIButton *btn = [UIButton new];
    btn.backgroundColor = UIColor.blueColor;
    [btn setTitle:@"收藏" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    btn.bounds = CGRectMake(0, 0, 100, 44);
    
    
    return @[deleteBtn, btn];
}

@end
