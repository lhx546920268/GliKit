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
#import <objc/message.h>
#import <GliKitDemo-Swift.h>
#import <GKIndexSearchBar.h>


@interface GKDParent : NSObject

@end

@implementation GKDParent

+ (void)initialize
{
    NSLog(@"GKDParent initialize %@", self.gkNameOfClass);
}

@end

@interface GKDChild : GKDParent

@end

@implementation GKDChild

+ (void)initialize
{
    NSLog(@"GKDChild initialize %@", self.gkNameOfClass);
}

@end


@interface DemoObservable : GKObject

///x
@property(nonatomic, assign) int intValue;

///x
@property(nonatomic, assign) NSInteger integerValue;

///x
@property(nonatomic, copy) NSString *stringValue;

///
@property(nonatomic, assign) CGFloat cgFloatValue;

///
@property(nonatomic, assign) double doubleValue;

///
@property(nonatomic, assign) float floatValue;

///
@property(nonatomic, assign) BOOL boolValue;

///
@property(nonatomic, assign) unsigned int uIntValue;


@end

@implementation DemoObservable

- (int)intValue
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    NSLog(@"setSelected %d", selected);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    NSLog(@"setHighlighted %d", highlighted);
}

@end

@interface UIViewController (Test)

@property(nonatomic, assign) BOOL change;

@end

@implementation UIViewController (Test)

- (void)setChange:(BOOL)change
{
    objc_setAssociatedObject(self, "change", @(change), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)change
{
    return [objc_getAssociatedObject(self, "change") boolValue];
}

@end

typedef struct SUser
{
    NSString *name;
    int age;
}User;

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

///x
@property(nonatomic, strong) DemoObservable *demo;

///
@property(nonatomic, strong) Class cls;

///
@property(nonatomic, copy) dispatch_block_t gcdBlock;

@end

@implementation GKDRootViewController

- (void)dealloc
{
    NSLog(@"GKDRootViewController dealloc");
}

- (void)testEncode:(const char*) encode one:(NSInteger) one str:(NSString*) str
{
    
}

- (void)test:(CGRect) a, ...
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    GKDParent *parent = GKDParent.new;
//
////    GKDChild *child = GKDChild.new;
//
//
//    [self addObserver:self forKeyPath:@"change" options:NSKeyValueObservingOptionNew context:nil];
//
//    self.change = YES;
    self.navigationItem.title = GKAppUtils.appName;
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"user/photo"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"skeleton"],
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

    [self gkSetLeftItemWithTitle:@"左边" action:nil];
//
//    self.demo = [DemoObservable new];
//    [self.demo.kvoHelper addObserver:self callback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
//        if(oldValue != newValue){
//            NSLog(@"%@, %@, %@", keyPath, newValue, oldValue);
//        }
//    } forKeyPath:@"intValue"];
//
//    [self.demo.kvoHelper addObserver:self manualCallback:^(NSString * _Nonnull keyPath, NSNumber*  _Nullable newValue, NSNumber*  _Nullable oldValue) {
//        NSLog(@"manualCallback %@, %@, %@", keyPath, newValue, oldValue);
//    } forKeyPath:@"integerValue"];
//
//    GKDRowModel *model = GKDRowModel.new;
//    [model setValue:@"string value" forKey:@"stringValue"];
//    self.cls = self.class;
//
//    NSString *name = @"名字";
//    name = [name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
//    NSLog(@"name %@", name.stringByRemovingPercentEncoding);
//
//    NSString *str = [NSString stringWithFormat:@"http://user/name?name=%@&age=1&stc=xai", name];
//    NSURLComponents *components = [NSURLComponents componentsWithString:str];
//
//    components.scheme = @"app";
//    NSLog(@"%@", components.URL.absoluteString);

    GKIndexSearchBar *searchBar = [GKIndexSearchBar new];
    searchBar.indexTitles = @[@"热", @"全", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"#"];
    searchBar.indexDidChange = ^(NSUInteger index, NSString *title) {
    
        NSLog(@"%lu, %@", (unsigned long)index, title);
    };
    
    [self.view addSubview:searchBar];
    
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
            make.trailing.equalTo(-10);
    }];
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
//    [CATransaction begin];
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
//    animation.fromValue = @(tap.view.center.y);
//    animation.toValue = @(300);
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;
//    animation.duration = 1;
//
//    [CATransaction setCompletionBlock:^{
//        NSLog(@"%f", tap.view.layer.position.y);
//        NSLog(@"%f", tap.view.center.y);
//    }];
//
//    [tap.view.layer addAnimation:animation forKey:@"p"];
//
//    [CATransaction commit];
    
    [UIView animateWithDuration:1 animations:^{
            tap.view.center = CGPointMake(tap.view.center.x, 300);
        } completion:^(BOOL finished) {
            NSLog(@"%f", tap.view.layer.position.y);
            NSLog(@"%f", tap.view.center.y);
        }];
    
    dispatch_main_after(0.5, ^{
        NSLog(@"%f", tap.view.layer.position.y);
    });
}

- (void)setChange:(BOOL)change
{
    NSLog(@"will change");
    [super setChange:change];
    NSLog(@"did change");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@, %@", keyPath, change);
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:GKDRootListCell.class];
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
//    @throw [NSException exceptionWithName:@"我自己爬出的" reason:@"" userInfo:nil];
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

//    self.demo.intValue = indexPath.row;
//    self.demo.integerValue = indexPath.row;
//    if(indexPath.row == 5){
//        [self.demo.kvoHelper flushManualCallback];
//    }
    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
    [GKRouter.sharedRouter open:^(GKRouteConfig * _Nonnull config) {
        config.path = model.className;
    }];
//    NSString *url = [NSString stringWithFormat:@"zegocity://www.zegocity.com/app/web?url=%@", [@"https://www.baidu.com" stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
//    [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
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
