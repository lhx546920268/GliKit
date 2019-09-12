//
//  GKDSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDSkeletonViewController.h"
#import "GKDNormalSkeletonViewController.h"
#import "GKDTableViewSkeletonViewController.h"
#import "GKDCollectionViewSkeletonViewController.h"

@interface GKDSkeletonViewController ()

@property(nonatomic, strong) NSArray *datas;

@end

@implementation GKDSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"骨架";
    self.datas = @[@"普通视图", @"TableView", @"CollectionView"];
    
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
    
    cell.textLabel.text = self.datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0 :
            [self.navigationController pushViewController:[GKDNormalSkeletonViewController new] animated:YES];
            break;
        case 1 :
            [self.navigationController pushViewController:[GKDTableViewSkeletonViewController new] animated:YES];
            break;
        case 2 :
            [self.navigationController pushViewController:[GKDCollectionViewSkeletonViewController new] animated:YES];
            break;
        default:
            break;
    }
}

@end
