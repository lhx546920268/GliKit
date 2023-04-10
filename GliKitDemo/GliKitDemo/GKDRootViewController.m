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
#import <NSJSONSerialization+GKUtils.h>
#import <SDWebImageDownloader.h>
#import <objc/runtime.h>

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@interface GKDRootListCell : GKTableViewSwipeCell

///
@property(nonatomic, readonly) UILabel *titleLabel;
@end

@implementation GKDRootListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [UILabel new];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
            make.leading.equalTo(15);
        }];
    }
    
    return self;
}

@end

@interface MYView : UIView

@end

@implementation MYView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [super hitTest:point withEvent:event];
}

@end

@interface GKDRootViewController ()<NSURLSessionDataDelegate, UIGestureRecognizerDelegate>

///
@property(nonatomic, strong) NSURLSession *session;

///
@property(nonatomic, assign) NSTimeInterval startTime;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = GKAppUtils.appName;
    
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"user/photo"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"skeleton"],
                   [GKDRowModel modelWithTitle:@"过渡" clazz:@"GKDTransitionViewController"],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"/app/nested"],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   [GKDRowModel modelWithTitle:@"Dynamic" clazz:@"/app/dynimic"],
                   ];

//    [self initViews];
     

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 300)];
    view.backgroundColor = UIColor.redColor;
    view.tag = 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    tap.delegate = self;
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    
    view = [[MYView alloc] initWithFrame:CGRectMake(0, 100, 200, 200)];
    view.backgroundColor = UIColor.blueColor;
    view.tag = 3;
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;

    [view addGestureRecognizer:pan];
    [self.view addSubview:view];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:RootListCell.class];
    [self registerClass:GKDRootListCell.class];
    [super initViews];
}

- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    NSLog(@"%ld", pan.view.tag);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return gestureRecognizer.view.tag != 3;
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDRootListCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDRootListCell.gkNameOfClass forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    NSString *title = self.datas[indexPath.row % self.datas.count].title;
    cell.titleLabel.text = title;
    cell.titleLabel.textColor = UIColor.blackColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = UIColor.redColor;
    cell.swipeDirection = GKSwipeDirectionLeft | GKSwipeDirectionRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"www.baidu.com"]];
//    NSString *encodedURL = [@"https://devtest.zegobird.com:11111/public/pages/coupon/index.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *str = [NSString stringWithFormat:@"zegodealer:///app/web?url=%@", encodedURL];
//    [UIApplication.sharedApplication openURL:[NSURL URLWithString:str]];
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
