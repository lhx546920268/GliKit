//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <objc/runtime.h>
#import <GKAppUtils.h>
#import <Social/Social.h>

@interface CustomActivity : UIActivity

@end

@implementation CustomActivity

- (NSString *)activityTitle
{
    return @"这是一个标题";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"warehouse"];
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
                   ];
    [self initViews];
    
    [self gkSetRightItemWithTitle:@"完成" action:nil];

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
    
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[@"这是一个标题", [UIImage imageNamed:@"warehouse"], [NSURL URLWithString:@"https://www.baidu.com"]] applicationActivities:nil];
    
    NSMutableArray *excludeTypesM =  [NSMutableArray arrayWithArray:@[//UIActivityTypePostToFacebook,
                                                                       UIActivityTypePostToTwitter,
                                                                       UIActivityTypePostToWeibo,
                                                                       UIActivityTypeMessage,
                                                                       UIActivityTypeMail,
                                                                       UIActivityTypePrint,
                                                                       UIActivityTypeCopyToPasteboard,
                                                                       UIActivityTypeAssignToContact,
                                                                       UIActivityTypeSaveToCameraRoll,
                                                                       UIActivityTypeAddToReadingList,
                                                                       UIActivityTypePostToFlickr,
                                                                       UIActivityTypePostToVimeo,
                                                                       UIActivityTypePostToTencentWeibo,
                                                                       UIActivityTypeAirDrop,
                                                                       UIActivityTypeOpenInIBooks]];
     
     if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {
         [excludeTypesM addObject:UIActivityTypeMarkupAsPDF];
     }
    vc.excludedActivityTypes = excludeTypesM;
    vc.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
    };
    [self presentViewController:vc animated:YES completion:nil];
//    GKDRowModel *model = self.datas[indexPath.row];
//    [GKRouter.sharedRouter pushApp:model.className];
}

@end
