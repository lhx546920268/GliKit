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
#import <GKHttpSessionManager.h>

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
 
    self.navigationItem.title = @"过渡";
    self.navigatonBar.tintColor = UIColor.whiteColor;

    self.navigatonBar.backgroundColor = UIColor.redColor;
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
    
//    NSDictionary *params = @{
//        @"sn" : @"33A20EF4-FEDC-498E-A32A-3FCA01B394AD_iPhone12,1",
//        @"clientType" : @2,
//        @"timestamp" : @1686275207954,
//        @"language" : @"zh-Hans",
//        @"sign" : @"QA420n+IoutPC4Ah+XhVb7eP9Cc="
//    };
//
//
//    NSDictionary *headers = @{
//        @"response-language": @"zh-Hans",
//        @"sn": @"33A20EF4-FEDC-498E-A32A-3FCA01B394AD_iPhone12,1"
//    };
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.50.172:9180/api/center/member/login/getAuthorizationUrl"]];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
//    for (NSString *key in headers) {
//        [request addValue:headers[key] forHTTPHeaderField:key];
//    }
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
//    }] resume];

//    [[GKHttpSessionManager.sharedManager dataTaskWithHTTPMethod:@"POST" URLString: parameters:params headerFields:headers timeoutInterval:30 success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull res) {
//            NSLog(@"成功 %@", res);
//        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//            NSLog(@"失败 %@", error);
//        }] resume];
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

#ifdef DEBUG

@interface NSDictionary (CALog)

@end

@implementation NSDictionary (CALog)

// NSLog字典对象时会调用此方法，将里面的中文在控制台打印出来
- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    // 以下为两种方式结合处理
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSString *logString;
        @try {
            logString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        } @catch (NSException *exception) {
            logString = [NSString stringWithFormat:@"打印字典时转换失败：%@",exception.reason];
        } @finally {
            return logString;
        }
    }
    
    NSMutableString *string = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    [string appendString:@"}\n"];
    return string;
}

@end

#endif
