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

@interface OriginObject : NSObject

- (void)originMethod;

@end

@implementation OriginObject

- (void)originMethod
{
    NSLog(@"originMethod");
    NSLog(@"%@", self);
}

@end

@interface ReplaceObject : NSObject

- (void)replaceMethod;

@end

@implementation ReplaceObject

- (void)replaceMethod
{
    NSLog(@"replaceMethod");
    NSLog(@"%@", self);
}

@end

@interface GKDNavigationBarTitleView : UIView


///内容
@property(nonatomic, readonly) UIView *contentView;

@end

@implementation GKDNavigationBarTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [UIView new];
        [self addSubview:_contentView];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            
            if(@available(iOS 11, *)){
                make.height.equalTo(frame.size.height);
            }
        }];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(200, UILayoutFittingExpandedSize.height);
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

///xx
@property(nonatomic, strong) NSPointerArray *pointerArray;

///xx
@property(nonatomic, strong) NSMapTable *mapTable;

///xx
@property(nonatomic, strong) NSHashTable *hashTable;

///xx
@property(nonatomic, strong) NSString *xxStr;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.aac = @"aac";
    self.abc = @"abc";
    
    self.xxStr = @"Pointer";
    
    self.pointerArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    self.mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    self.hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    
  
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
                   ];
  
    [self initViews];
    
    Method method1 = class_getInstanceMethod(OriginObject.class, @selector(originMethod));
    Method method2 = class_getInstanceMethod(ReplaceObject.class, @selector(replaceMethod));
    method_exchangeImplementations(method1, method2);
    
    [OriginObject.new originMethod];
    [ReplaceObject.new replaceMethod];
    
    GKDNavigationBarTitleView *titleView = [[GKDNavigationBarTitleView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 30)];
    UIView *view = UIView.new;
    view.backgroundColor = UIColor.redColor;
    view.layer.cornerRadius = 10;
    
    [titleView.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(0);
    }];
    
    self.navigationItem.titleView = titleView;
    
    [self gkSetLeftItemWithTitle:@"左边" action:nil];
//    [self gkSetRightItemWithTitle:@"右边" action:nil];
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
