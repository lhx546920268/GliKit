//
//  GKNavigationItemHelper.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/6/5.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKNavigationItemHelper.h"

@interface GKNavigationItemHelper ()

@end

@implementation GKNavigationItemHelper

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
        _hiddenItem = NO;
    }
    
    return self;
}

- (void)setHiddenItem:(BOOL)hiddenItem
{
    if(_hiddenItem != hiddenItem){
        _hiddenItem = hiddenItem;
        if(_hiddenItem){
            [self hideAndSaveItem];
        }else{
            [self restoreItem];
        }
    }
}

///隐藏并且保存item的状态
- (void)hideAndSaveItem
{
    UINavigationItem *item = self.viewController.navigationItem;
    
    self.title = item.title;
    self.viewControllerTitle = self.viewController.title;
    self.titleView = item.titleView;
    
    self.leftBarButtonItem = item.leftBarButtonItem;
    self.leftBarButtonItems = item.leftBarButtonItems;
    
    self.rightBarButtonItem = item.rightBarButtonItem;
    self.rightBarButtonItems = item.rightBarButtonItems;
    
    self.viewController.title = nil;
    item.title = nil;
    item.titleView = nil;
    
    item.leftBarButtonItem = nil;
    item.leftBarButtonItems = nil;
    
    item.rightBarButtonItem = nil;
    item.rightBarButtonItems = nil;
}

///恢复上一次保存的item
- (void)restoreItem
{
    UINavigationItem *item = self.viewController.navigationItem;
    
    self.viewController.title = self.viewControllerTitle;
    item.title = self.title;
    item.titleView = self.titleView;
    
    if(self.leftBarButtonItems.count > 0){
        item.leftBarButtonItems = self.leftBarButtonItems;
    }else{
        item.leftBarButtonItem = self.leftBarButtonItem;
    }
    
    if(self.rightBarButtonItems.count > 0){
        item.rightBarButtonItems = self.rightBarButtonItems;
    }else{
        item.rightBarButtonItem = self.rightBarButtonItem;
    }
}

@end
