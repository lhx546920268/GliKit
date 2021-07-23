//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GliKitDemo-Swift.h>
#import <GKAppUtils.h>

@interface GKParent : NSObject<NSCopying>

@property(nonatomic, copy) NSString *name;

@end

@implementation GKParent

GKConvenientCopying

@end

@interface GKChild : GKParent

@property(nonatomic, copy) NSString *childName;

@end

@implementation GKChild

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = GKAppUtils.appName;
    
    CGSize size = CGSizeMake(120, 120);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, size.width, size.width)];
    view.backgroundColor = UIColor.redColor;
    [self.view addSubview:view];
    
    UIColor *color = UIColor.whiteColor;
    CALayer *layer = view.layer;
    
    CGFloat circleSpacing = 2;
    CGFloat circleSize = (size.width - 2 * circleSpacing) / 4;
    CGFloat x = (layer.bounds.size.width - size.width) / 2;
    CGFloat y = (layer.bounds.size.height - circleSize) / 2;
    CFTimeInterval duration = 0.5;
    CFTimeInterval beginTime = CACurrentMediaTime();
    CFTimeInterval beginTimes[] = {0, 0.125, 0.25, 0.375};
    CAMediaTimingFunction *timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.2 :0.68 :0.18 :1.08];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];

    animation.fromValue = @1.0;
    animation.toValue = @0.2;
    // Animation
//    animation.keyTimes = @[@0, @0.3, @1];
//    animation.timingFunctions = @[timingFunction, timingFunction];
//    animation.values = @[@1, @0.3, @1];
    animation.duration = duration;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = NO;
    animation.autoreverses = YES;

    // Draw circles
    for(NSInteger i = 0;i < 4;i ++) {
        CALayer *circle = [CALayer layer];
        circle.backgroundColor = color.CGColor;
        circle.cornerRadius = circleSize / 2;
        
        CGRect frame = CGRectMake(x + circleSize * i + circleSpacing * i, y, circleSize, circleSize);

        animation.beginTime = beginTime + beginTimes[i];
        circle.frame = frame;
        [circle addAnimation:animation forKey:@"animation"];
        [layer addSublayer:circle];
    }
//    self.datas = @[
//                   [GKDRowModel modelWithTitle:@"相册" clazz:@"user/photo"],
//                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"skeleton"],
//                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:@"GKDTransitionViewController"],
//                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"GKDNestedParentViewController"],
//                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
//                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
//                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
//                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
//                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
//                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
//                   ];
//
//    [self initViews];
//
//    [self gkSetLeftItemWithTitle:@"左边" action:nil];
//
//    GKChild *child = [GKChild new];
//    child.name = @"niy";
//    child.childName = @"viy";
//
//    GKChild *val = [child copy];
    
//    NSLog(@"cls %@", val.childName);
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:RootListCell.class];
    [super initViews];
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootListCell *cell = [tableView dequeueReusableCellWithIdentifier:RootListCell.gkNameOfClass forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
    [GKRouter.sharedRouter open:^(GKRouteConfig * _Nonnull config) {
        config.path = model.className;
    }];
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
