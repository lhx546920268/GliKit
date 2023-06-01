//
//  GKDTransitionViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/5.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTransitionViewController.h"
#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GKTableViewController.h>
#import <GKNavigationBar.h>

@interface GKDLabel : UILabel

@end

@implementation GKDLabel

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
    NSLog(@"drawLayer %@", layer);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    NSLog(@"layoutSublayersOfLayer %@", layer);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSLog(@"sizeThatFits");
    return [super sizeThatFits:size];
}

@end

@interface GKDListViewController : GKTableViewController

@end

@implementation GKDListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dialogShowAnimate = GKDialogAnimateFromBottom;
    self.dialogDismissAnimate = GKDialogAnimateFromBottom;
    [self.dialog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
        make.height.equalTo(300);
    }];
    [self initViews];
}

- (void)initViews
{
    [self registerClass:[UITableViewCell class]];
    [super initViews];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.gkNameOfClass forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第 %ld 个", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [GKRouter.sharedRouter open:^(GKRouteConfig * _Nonnull config) {
        config.path = @"/app/transition";
    }];
}

@end

@interface GKDTransitionViewController ()

@property(nonatomic, strong) GKDLabel *label;

@end

@implementation GKDTransitionViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"/app/transition" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDTransitionViewController new];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigatonBar.backgroundColor = UIColor.clearColor;
    // Do any additional setup after loading the view from its nib.
//    myStaticTest = @"xxx";
    GKDLabel *label = [GKDLabel new];
    label.text = @"demo";
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change)]];
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(0);
            make.top.equalTo(200);
    }];
    self.label = label;
}

- (void)change
{
//    self.label.text = @"change";
    NSLog(@"%@", NSStringFromCGRect(self.label.frame));
    self.label.layer.anchorPoint = CGPointMake(0.4, 0.4);
    NSLog(@"%@", NSStringFromCGRect(self.label.frame));
}

- (IBAction)handleFromBottom:(UIButton*)sender
{
//    UIViewController *vc = [UIViewController new];
//    vc.navigationItem.title = sender.currentTitle;
//    vc.view.backgroundColor = UIColor.whiteColor;
//
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//
//    nav.partialPresentProps.contentSize = CGSizeMake(UIScreen.gkWidth, 400);
//    nav.partialPresentProps.cornerRadius = 10;
//    nav.partialPresentProps.dismissCallback = ^{
//        NSLog(@"dialogDismissCompletionHandler");
//    };
//    [nav partialPresentFromBottom];
    
    [self handleTap:nil];
}

- (void)handleTap:(UIButton*) sender
{
//    GKDRootViewController *vc = [GKDRootViewController new];
//    vc.navigationItem.title = sender.currentTitle;
//    vc.view.backgroundColor = UIColor.whiteColor;
//    vc.gkShowBackItem = YES;
//
//    UINavigationController *nav = vc.gkCreateWithNavigationController;
//
//        nav.partialPresentProps.contentSize = CGSizeMake(UIScreen.gkWidth, 400);
//        nav.partialPresentProps.cornerRadius = 10;
//        nav.partialPresentProps.dismissCallback = ^{
//            NSLog(@"dialogDismissCompletionHandler");
//        };
//    [nav partialPresentFromBottom];
    
    GKDListViewController *vc = [GKDListViewController new];
    [vc showAsDialogInViewController:self layoutHandler:nil];
}

@end
