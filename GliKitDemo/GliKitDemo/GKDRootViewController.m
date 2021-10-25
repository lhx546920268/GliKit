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

@interface CATextContainer : NSTextContainer

@end

@implementation CATextContainer
//
//- (CGSize)size
//{
//    CGSize size = [super size];
//    NSLog(@"%@", NSStringFromCGSize(size));
//    return size;
//}

@end

@interface CALayoutManager : NSLayoutManager

@end

@implementation CALayoutManager

- (CGRect)usedRectForTextContainer:(NSTextContainer *)container
{
    CGRect rect = [super usedRectForTextContainer:container];
    NSLog(@"%@", NSStringFromCGRect(rect));
//    rect.size.height += 10;
    return rect;
}

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = GKAppUtils.appName;
    
    NSTextStorage *textStorage = [NSTextStorage new];

    CALayoutManager *layoutManager = [CALayoutManager new];
    [textStorage addLayoutManager: layoutManager];

    NSTextContainer *container = [CATextContainer new];
    container.lineFragmentPadding = 0;
    [layoutManager addTextContainer:container];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:container];
    textView.backgroundColor = UIColor.redColor;
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    textView.text = @"အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊အမှတ်-၇၄၂၊ရွှေနှန်းဆီလမ်း၊မဟာစည်ရိပ်ကျောင်းတိုက်ဘေး၊မရမ်းကုန်းမြို့နယ်၊ရန်ကုန်မြို့၊";
    [self.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(20);
        make.top.equalTo(150);
        make.trailing.equalTo(-20);
        make.height.equalTo(100);
    }];

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
    

//    [self initViews];

    [self gkSetLeftItemWithTitle:@"左边" action:nil];
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
    
    NSString *title = self.datas[indexPath.row % self.datas.count].title;
    if (indexPath.row % 2 == 0) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:title];
        [attr addAttribute:NSStrokeWidthAttributeName value:@(-2) range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSStrokeColorAttributeName value:UIColor.blackColor range:NSMakeRange(0, attr.length)];
        cell.textLabel.attributedText = attr;
    } else {
    cell.textLabel.text = title;
    }
    
    UIFont *font = [UIFont fontWithName:@"NotoSansMyanmar-Medium" size:17];
    NSLog(@"%@", font);
    cell.textLabel.font = font;
    cell.textLabel.textColor = UIColor.blackColor;
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
