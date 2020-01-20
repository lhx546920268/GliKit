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
#import <MessageUI/MessageUI.h>

@interface GKDShareViewController : GKBaseViewController<MFMessageComposeViewControllerDelegate>

@end

@implementation GKDShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"SMS" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleSMS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
    }];
}

- (void)handleSMS
{
    MFMessageComposeViewController *vc = [MFMessageComposeViewController new];
    vc.body = @"你好";
    vc.messageComposeDelegate = self;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

- (CGSize)partialContentSize
{
    return CGSizeMake(UIScreen.gkScreenWidth, 300);
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

static NSString* Name1 = @"1";
static NSString* Name2 = @"2";

@interface UIViewController(exten)

@property(nonatomic, copy) NSString *name1;
@property(nonatomic, copy) NSString *name2;

@end

@implementation UIViewController(exten)

- (void)setName1:(NSString *)name1
{
    objc_setAssociatedObject(self, Name1.UTF8String, name1, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name1
{
    return objc_getAssociatedObject(self, Name1.UTF8String);
}

- (void)setName2:(NSString *)name2
{
    objc_setAssociatedObject(self, Name2.UTF8String, name2, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name2
{
    return objc_getAssociatedObject(self, Name2.UTF8String);
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationItem.title = GKAppUtils.appName;
    //^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$
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
    
    NSLog(@"%@, %@", Name1, Name2);
    
    self.name1 = @"name1";
    self.name2 = @"name2";
    
    NSLog(@"%@, %@", Name1, Name2);
    NSLog(@"%@, %@", self.name1, self.name2);
    
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
  
    GKDRowModel *model = self.datas[indexPath.row];
    [GKRouter.sharedRouter pushApp:model.className];
}

@end
