//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GKAppUtils.h>
#import <GKTableViewSwipeCell.h>
#import <GKObject.h>
#import <GKKVOHelper.h>
#import <objc/runtime.h>

@interface DemoObservable : GKObject

///x
@property(nonatomic, assign) NSInteger intValue;

///x
@property(nonatomic, assign) NSInteger integerValue;

///x
@property(nonatomic, copy) NSString *stringValue;

///
@property(nonatomic, assign) CGSize sizeValue;

@end

@implementation DemoObservable

- (NSInteger)intValue
{
    return _intValue == 0 ? 10 : _intValue;
}

- (NSInteger)integerValue
{
    return _integerValue == 0 ? 1 : _integerValue;
}

- (void)testxx
{
    NSLog(@"DemoObservable testxx");
}

@end

@interface GKDRootListCell : GKTableViewSwipeCell

@end

@implementation GKDRootListCell

@end

@interface GKDRowModel(Readonly)

@property(nonatomic, copy) NSString *stringValue;

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

///x
@property(nonatomic, strong) DemoObservable *demo;

///
@property(nonatomic, strong) Class cls;

@end

@implementation GKDRootViewController

- (void)dealloc
{
    NSLog(@"GKDRootViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    self.navigationItem.title = GKAppUtils.appName;
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"photo"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"GKDSkeletonViewController"],
                   [GKDRowModel modelWithTitle:@"UIViewController 过渡" clazz:@"GKDTransitionViewController"],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"GKDNestedParentViewController"],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   ];

    [self initViews];

    CGRect rect = {1, 2, 3, 5};
    NSLog(@"rect = %@", NSStringFromCGRect(rect));
    [self gkSetLeftItemWithTitle:@"左边" action:nil];
    
    self.demo = [DemoObservable new];
    [self.demo.kvoHelper addObserver:self callback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
        if(oldValue != newValue){
            NSLog(@"%@, %@, %@", keyPath, newValue, oldValue);
        }
    } forKeyPath:@"intValue"];
    
    [self.demo.kvoHelper addObserver:self manualCallback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
        NSLog(@"manualCallback %@, %@, %@", keyPath, newValue, oldValue);
    } forKeyPath:@"integerValue"];
    
    GKDRowModel *model = GKDRowModel.new;
    [model setValue:@"string value" forKey:@"stringValue"];
    self.cls = self.class;
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:GKDRootListCell.class];
    [super initViews];
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    @throw [NSException exceptionWithName:@"我自己爬出的" reason:@"" userInfo:nil];
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDRootListCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDRootListCell.gkNameOfClass forIndexPath:indexPath];
    
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
    
//    self.demo.intValue = indexPath.row;
//    self.demo.integerValue = indexPath.row;
//    if(indexPath.row == 5){
//        [self.demo.kvoHelper flushManualCallback];
//    }
//    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
//    [GKRouter.sharedRouter open:^(GKRouteProps * _Nonnull props) {
//        props.path = model.className;
//    }];
    SEL selector = NSSelectorFromString(@"testxx");
    [self performSelector:selector];
    selector = NSSelectorFromString(@"runtimeTest");
    [self performSelector:selector];
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

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"resolveInstanceMethod %@", NSStringFromSelector(sel));
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"forwardingTargetForSelector %@", NSStringFromSelector(aSelector));
//    if(aSelector == NSSelectorFromString(@"testxx")){
//        return self.demo;
//    }
    return [super forwardingTargetForSelector:aSelector];
}

- (IMP)methodForSelector:(SEL)aSelector
{
    NSLog(@"methodForSelector %@", NSStringFromSelector(aSelector));
    return [super methodForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    Method method = class_getInstanceMethod(self.demo.class, aSelector);
    class_addMethod(self.class, aSelector, [self.demo methodForSelector:aSelector], method_getTypeEncoding(method));
    NSLog(@"methodSignatureForSelector %@", NSStringFromSelector(aSelector));
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"forwardInvocation %@", NSStringFromSelector(anInvocation.selector));
    [super forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"doesNotRecognizeSelector %@", NSStringFromSelector(aSelector));
}

- (void)runtimeTest
{
    NSLog(@"runtimeTest");
}

@end
