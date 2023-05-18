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
#import <GKPopoverMenu.h>

@interface SRRunLoopThread : NSThread

@property (nonatomic, strong, readonly) NSRunLoop *runLoop;

+ (instancetype)sharedThread;

@end

@interface SRRunLoopThread ()
{
    dispatch_group_t _waitGroup;
}

@property (nonatomic, strong, readwrite) NSRunLoop *runLoop;

@end

@implementation SRRunLoopThread

+ (instancetype)sharedThread
{
    static SRRunLoopThread *thread;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[SRRunLoopThread alloc] init];
        thread.qualityOfService = NSQualityOfServiceUserInitiated;
        thread.name = @"com.facebook.SocketRocket.NetworkThread";
        [thread start];
    });
    return thread;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _waitGroup = dispatch_group_create();
        dispatch_group_enter(_waitGroup);
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        NSLog(@"Thread main");
        _runLoop = [NSRunLoop currentRunLoop];
        dispatch_group_leave(_waitGroup);
        
        // Add an empty run loop source to prevent runloop from spinning.
        CFRunLoopSourceContext sourceCtx = {
            .version = 0,
            .info = NULL,
            .retain = NULL,
            .release = NULL,
            .copyDescription = NULL,
            .equal = NULL,
            .hash = NULL,
            .schedule = NULL,
            .cancel = NULL,
            .perform = NULL
        };
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(NULL, 0, &sourceCtx);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
        CFRelease(source);
        
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"count down %@", NSThread.currentThread.name);
        }];

        while ([_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            NSLog(@"while runMode");
        }

//        [_runLoop run];
        NSLog(@"run end");
        assert(NO);
    }
}

- (NSRunLoop *)runLoop;
{
    NSLog(@"get runloop");
    dispatch_group_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    NSLog(@"x runloop");
    return _runLoop;
}

@end

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

@interface CircleView : UIView

@end

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initProps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initProps];
    }
    return self;
}

- (void)initProps
{
    self.opaque = NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, UIColor.redColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor.CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    CGFloat radius = 10;
    CGFloat arrowSize = 10;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = rect.size.width;
    CGFloat maxY = rect.size.height - arrowSize;
    CGFloat midX = rect.size.width / 2;
    
    CGContextMoveToPoint(ctx, midX + arrowSize, maxY);
    CGContextAddLineToPoint(ctx, midX, maxY + arrowSize);
    CGContextAddLineToPoint(ctx, midX - arrowSize, maxY);
    
    CGContextAddArcToPoint(ctx, minX, maxY, minX, minY, radius);
    CGContextAddArcToPoint(ctx, minX, minY, maxX, minY, radius);
    CGContextAddArcToPoint(ctx, maxX, minY, maxX, maxY, radius);
    CGContextAddArcToPoint(ctx, maxX, maxY, midX, maxY, radius);
    
    CGContextClosePath(ctx);
//    CGContextStrokePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
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
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"/app/alert"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   [GKDRowModel modelWithTitle:@"Dynamic" clazz:@"/app/dynimic"],
                   ];

    [self initViews];
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:RootListCell.class];
    [self registerClass:GKDRootListCell.class];
    [self gkSetRightItemWithTitle:@"Popover" action:@selector(handlePopover)];
    
    [super initViews];
}

- (void)handlePopover
{
    GKPopoverMenu *menu = [[GKPopoverMenu alloc] initWithTitles:@[@"首页", @"购物车"]];
    menu.strokeColor = UIColor.redColor;
    menu.strokeWidth = 2;
    [menu showInView:self.navigationController.view anchorView:self.navigationItem.rightBarButtonItem.customView animated:YES];
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
