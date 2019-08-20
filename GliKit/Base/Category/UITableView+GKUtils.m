//
//  UITableView+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UITableView+GKUtils.h"

@implementation UITableView (GKUtils)

- (void)setExtraCellLineHidden
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableFooterView = nil;
    self.tableFooterView = view;
}

- (void)registerNib:(Class)clazz
{
    NSString *name = NSStringFromClass(clazz);
    [self registerNib:[UINib nibWithNibName:name bundle:nil] forCellReuseIdentifier:name];
}

- (void)registerClass:(Class) clazz
{
    [self registerClass:clazz forCellReuseIdentifier:NSStringFromClass(clazz)];
}

- (void)registerNibForHeaderFooterView:(Class)clazz
{
    NSString *name = NSStringFromClass(clazz);
    [self registerNib:[UINib nibWithNibName:name bundle:nil] forHeaderFooterViewReuseIdentifier:name];
}

- (void)registerClassForHeaderFooterView:(Class)clazz
{
    [self registerClass:clazz forHeaderFooterViewReuseIdentifier:NSStringFromClass(clazz)];
}

@end
