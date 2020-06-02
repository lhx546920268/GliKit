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

@interface GKDStream : NSObject
{
    CFWriteStreamRef writeStream;
    CFReadStreamRef readStream;
}

- (void)initStream;

@end

@implementation GKDStream

- (void)onTack
{
    NSLog(@"GKDStream onTack");
}

- (void)initStream
{
    CFStreamCreatePairWithSocketToHost(NULL, CFBridgingRetain(@""), 0, &readStream, &writeStream);
    NSLog(@"readStream begin");
    if( random() % 2 == 0){
        [self releaseStream];
    }
}

- (void)releaseStream
{
    if(readStream){
        CFRelease(readStream);
        readStream = NULL;
    }
    
    if(writeStream){
        CFRelease(writeStream);
        writeStream = NULL;
    }
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
        self.opaque = NO;
        _contentView = [UIView new];
        [self addSubview:_contentView];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
    CGContextAddPath(context, [UIBezierPath bezierPathWithOvalInRect:rect].CGPath);
    CGContextDrawPath(context, kCGPathFill);

    CGContextRestoreGState(context);
    NSLog(@"drawRect");
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate>


@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@property(nonatomic, strong) NSLock *lock;

///xx
@property(nonatomic, strong) NSConditionLock *conditionLock;

///xx
@property(nonatomic, assign) int amount;

///xx
@property(nonatomic, strong) UIView *titleView;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conditionLock = [[NSConditionLock alloc] initWithCondition:2];

    self.lock = [NSLock new];
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
    

    [self gkSetLeftItemWithTitle:@"左边" action:nil];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:GKDStream.new];
    NSLog(@"forwardInvocation");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if(sel == @selector(onTack)){
        NSLog(@"resolveInstanceMethod");
        return NO;
    }
    
    return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    if(sel == @selector(onTack)){
        NSLog(@"resolveClassMethod");
        return YES;
    }
    
    return [super resolveClassMethod:sel];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"methodSignatureForSelector");
    
    NSMethodSignature *signature = [GKDStream instanceMethodSignatureForSelector:aSelector];
    
    return signature;
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"doesNotRecognizeSelector");
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
