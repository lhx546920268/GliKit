//
//  GKDEmptyViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDEmptyViewController.h"
#import "GKDRowModel.h"

@interface GKDEmptyViewController ()

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDEmptyViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"空视图";
    self.datas = @[[GKDRowModel modelWithTitle:@"普通视图" clazz:@"GKDNormalEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"TableView" clazz:@"GKDTableEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"CollectionView" clazz:@"GKDCollectionEmptyViewController"]];
    
    self.style = UITableViewStyleGrouped;
    [self initViews];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.datas[indexPath.row].title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [GKRouter.sharedRouter open:^(GKRouteProps * _Nonnull props) {
            props.path = self.datas[indexPath.row].className;
    }];
}
@end
