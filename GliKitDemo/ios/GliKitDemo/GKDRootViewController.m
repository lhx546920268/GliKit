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
#import <IAPHelper.h>
#import <IAPShare.h>

@interface GKDRootViewController ()<CAAnimationDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    [self gkSetRightItemWithTitle:@"完成" action:nil];

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
  NSSet* dataSet = [[NSSet alloc] initWithObjects:@"这里是iap商品id", nil];
    [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
   
  // 请求商品信息
  [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
      if(response.products.count > 0 ) {
       SKProduct *product = response.products[0];
   
       [[IAPShare sharedHelper].iap buyProduct:product
             onCompletion:^(SKPaymentTransaction* trans){
           if(trans.error)
           {
           }
           else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
      
   
            // 购买验证
            NSData *receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
            //网上的攻略有的比较老，在验证时使用的是trans.transactionReceipt，需要注意trans.transactionReceipt在ios9以后被弃用
            [[IAPShare sharedHelper].iap checkReceipt:receipt onCompletion:^(NSString *response, NSError *error) {}];
            
    
      }
      else if(trans.transactionState == SKPaymentTransactionStateFailed) {
            if (trans.error.code == SKErrorPaymentCancelled) {
            }else if (trans.error.code == SKErrorClientInvalid) {
            }else if (trans.error.code == SKErrorPaymentInvalid) {
            }else if (trans.error.code == SKErrorPaymentNotAllowed) {
            }else if (trans.error.code == SKErrorStoreProductNotAvailable) {
            }else{
            }
         }
      }];
      }else{
            //  ..未获取到商品
      }
     }];
    
    
//    GKDRowModel *model = self.datas[indexPath.row];
//    [GKRouter.sharedRouter pushApp:model.className];
}

@end
