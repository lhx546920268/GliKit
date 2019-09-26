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
#import "GKDRowModel.h"

@interface GKDSkeletonViewController ()

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@implementation GKDSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"骨架";
    self.datas = @[[GKDRowModel modelWithTitle:@"普通视图" clazz:GKDNormalSkeletonViewController.class],
                   [GKDRowModel modelWithTitle:@"TableView" clazz:GKDTableViewSkeletonViewController.class],
                   [GKDRowModel modelWithTitle:@"CollectionView" clazz:GKDCollectionViewSkeletonViewController.class]];
    
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
    [self.navigationController pushViewController:self.datas[indexPath.row].clazz.new animated:YES];
}

@end
