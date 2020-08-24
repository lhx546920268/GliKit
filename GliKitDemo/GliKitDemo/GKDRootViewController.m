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
#import <AFNetworking.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <libkern/OSAtomic.h>
#import <UIImageView+WebCache.h>


typedef void(^GKDCommonBlock)(void);

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate>

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
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   ];

    [self initViews];

    [self gkSetLeftItemWithTitle:@"左边" action:nil];
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
     NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
        while (true) {
            //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
            SymbolNode * node = OSAtomicDequeue(&symboList, offsetof(SymbolNode, next));
            if (node == NULL) break;
            Dl_info info;
            dladdr(node->pc, &info);
            
            NSString * name = @(info.dli_sname);
            
            // 添加 _
            BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
            NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
            
            //去重
            if (![symbolNames containsObject:symbolName]) {
                [symbolNames addObject:symbolName];
            }
        }

        //取反
        NSArray * symbolAry = [[symbolNames reverseObjectEnumerator] allObjects];
    //将结果写入到文件
        NSString * funcString = [symbolAry componentsJoinedByString:@"\n"];
        NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"lb.order"];
        NSData * fileContents = [funcString dataUsingEncoding:NSUTF8StringEncoding];
        BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
        if (result) {
            NSLog(@"%@",filePath);
        }else{
            NSLog(@"文件写入出错");
        }

}

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

//原子队列
static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;

//定义符号结构体
typedef struct{
    void * pc;
    void * next;
}SymbolNode;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return;  // Duplicate the guard check.
    void *PC = __builtin_return_address(0);
    SymbolNode * node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC,NULL};
    
    //入队
    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
    OSAtomicEnqueue(&symboList, node, offsetof(SymbolNode, next));
}

- (void)setAmount:(int)amount
{
    NSLog(@"%@, %@", [NSString stringWithUTF8String:__func__], NSStringFromSelector(_cmd));
}

- (int)amount
{
    NSLog(@"%@, %@", [NSString stringWithUTF8String:__func__], NSStringFromSelector(_cmd));
    return 0;
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
