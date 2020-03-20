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

static NSString* Name1 = @"1";
static NSString* Name2 = @"2";

@interface UIViewController(exten)

@property(nonatomic, copy) NSString *name1;

@end

@implementation UIViewController(exten)

+ (void)load
{
    NSLog(@"UIViewController exten 1");
}

- (void)setName1:(NSString *)name1
{
    objc_setAssociatedObject(self, Name1.UTF8String, name1, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name1
{
    return objc_getAssociatedObject(self, Name1.UTF8String);
}

@end

@interface GKDRowModel()

@property(nonatomic, copy) NSString *name2;

@end

@interface UIViewController(exten1)

@property(nonatomic, copy) NSString *name2;

@end

@implementation UIViewController(exten1)

+ (void)load
{
    NSLog(@"UIViewController exten 2");
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

@protocol RunTimeObjectProtocol <NSObject>

///
@property(nonatomic, assign) NSInteger assigValue;

@end

@interface RunTimeObject : NSObject<RunTimeObjectProtocol>
{
    NSString *vaValue;
}

///
@property(nonatomic, strong) NSString *stronValue;

///
@property(nonatomic, copy) NSString *copValue;

///
@property(nonatomic, weak) GKDRowModel *weaValue;

///
@property(nonatomic, readonly) NSString *readValue;

@end

@interface RunTimeObject()

@property(nonatomic, strong) NSString *extensionValue;

@end

@interface RunTimeObject()

@property(nonatomic, strong) NSString *extensionValue2;

@end

@implementation RunTimeObject

@synthesize readValue = _readValue;

+ (void)initialize
{
//    if (self == [RunTimeObject class]) {
        NSLog(@"RunTimeObject initialize");
//    }
}

- (void)setAssigValue:(NSInteger)assigValue
{
    
}

- (NSInteger)assigValue
{
    return 0;
}

- (NSString *)readValue
{
    return @"";
}

@end

@interface RunTimeChildObject : RunTimeObject

///
@property(nonatomic, copy) NSString *childCopValue;

@end

@implementation RunTimeChildObject

+ (void)initialize
{
//    if (self == [RunTimeChildObject class]) {
        NSLog(@"RunTimeChildObject initialize");
//    }
}

@end

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
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
                   ];
  
    [self initViews];
    
//    NSLog(@"%@", RunTimeObject.new);
    NSLog(@"%@", RunTimeChildObject.new);
    NSLog(@"%@, %@", Name1, Name2);
    
    self.name1 = @"name1";
    self.name2 = @"name2";
    
    NSLog(@"%@, %@", Name1, Name2);
    NSLog(@"%@, %@", self.name1, self.name2);
    
    [self gkSetRightItemWithTitle:@"完成" action:nil];
    
    NSLog(@"class_copyPropertyList");
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(RunTimeObject.class, &count);
    for(unsigned int i = 0;i < count;i ++){
        objc_property_t property = properties[i];
        NSLog(@"%@", [NSString stringWithUTF8String:property_getName(property)]);
    }
    
    NSLog(@"class_copyIvarList");
    count = 0;
    Ivar *iVars = class_copyIvarList(RunTimeObject.class, &count);
    for(unsigned int i = 0;i < count;i ++){
        Ivar iVar = iVars[i];
        NSLog(@"%@", [NSString stringWithUTF8String:ivar_getName(iVar)]);
    }
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
