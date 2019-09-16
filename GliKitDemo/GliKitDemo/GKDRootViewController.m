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

@interface GKDRootModel : NSObject

///xx
@property(nonatomic, strong) NSString *title;

///xx
@property(nonatomic, strong) Class clazz;

+ (instancetype)modelWithTitle:(NSString*) title clazz:(Class) clazz;

@end

@implementation GKDRootModel

+ (instancetype)modelWithTitle:(NSString *)title clazz:(Class)clazz
{
    GKDRootModel *model = GKDRootModel.new;
    model.title = title;
    model.clazz = clazz;
    
    return model;
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRootModel*> *datas;


@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = GKAppUtils.appName;
    
    self.datas = @[
                   [GKDRootModel modelWithTitle:@"相册" clazz:GKDPhotosViewController.class],
                   [GKDRootModel modelWithTitle:@"骨架" clazz:GKDSkeletonViewController.class],
                   [GKDRootModel modelWithTitle:@"UIViewController 过渡" clazz:GKDTransitionViewController.class],
                   [GKDRootModel modelWithTitle:@"嵌套滑动" clazz:GKDNestedParentViewController.class],
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GKDRootModel *model = self.datas[indexPath.row];
    [self.class gkPushViewController:model.clazz.new];
}

@end
