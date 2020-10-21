//
//  UITableView+GKSkeleton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UITableView+GKSkeleton.h"
#import "NSObject+GKUtils.h"
#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import "GKSkeletonHelper.h"

@implementation UITableView (GKSkeleton)

+ (void)load
{
    [self gkExchangeImplementations:@selector(setDelegate:) prefix:@"gkSkeleton_"];
    [self gkExchangeImplementations:@selector(setDataSource:) prefix:@"gkSkeleton_"];
}

- (void)gkSkeleton_setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegate){
        [GKSkeletonHelper replaceImplementations:@selector(tableView:didSelectRowAtIndexPath:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:viewForHeaderInSection:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:viewForFooterInSection:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:shouldHighlightRowAtIndexPath:) owner:delegate implementer:self];
    }
    
    [self gkSkeleton_setDelegate:delegate];
}

- (void)gkSkeleton_setDataSource:(id<UITableViewDataSource>)dataSource
{
    if(dataSource){
        [GKSkeletonHelper replaceImplementations:@selector(tableView:cellForRowAtIndexPath:) owner:dataSource implementer:self];
    }
    
    [self gkSkeleton_setDataSource:dataSource];
}

- (void)gkShowSkeletonWithDuration:(NSTimeInterval)duration completion:(GKShowSkeletonCompletionHandler)completion
{
    if(self.gkSkeletonStatus == GKSkeletonStatusNone){
        self.gkSkeletonStatus = GKSkeletonStatusShowing;
        [self reloadData];
        
        if(duration > 0 && completion){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), completion);
        }
    }
}

- (void)gkHideSkeletonWithAnimate:(BOOL)animate completion:(void (NS_NOESCAPE ^)(BOOL))completion
{
    GKSkeletonStatus status = self.gkSkeletonStatus;
    if(status == GKSkeletonStatusShowing){
        self.gkSkeletonStatus = GKSkeletonStatusWillHide;
        self.gkSkeletonHideAnimate = YES;
        [self reloadData];
    }
}

// MARK: - UITableViewDelegate

- (BOOL)gkSkeletonAdd_tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这是添加的方法
    return tableView.gkSkeletonStatus == GKSkeletonStatusNone;
}

- (BOOL)gkSkeleton_tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.gkSkeletonStatus != GKSkeletonStatusNone){
        return NO;
    }
    
    return [self gkSkeleton_tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}

- (UIView*)gkSkeleton_tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [self gkSkeleton_tableView:tableView viewForFooterInSection:section];
    [tableView gkSkeletonProcessView:view inContainer:tableView];
    
    return view;
}

- (UIView*)gkSkeleton_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [self gkSkeleton_tableView:tableView viewForHeaderInSection:section];
    [tableView gkSkeletonProcessView:view inContainer:tableView];
    
    return view;
}

- (UITableViewCell*)gkSkeleton_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self gkSkeleton_tableView:tableView cellForRowAtIndexPath:indexPath];
    [tableView gkSkeletonProcessView:cell.contentView inContainer:tableView];
    
    return cell;
}

- (void)gkSkeleton_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.gkSkeletonStatus != GKSkeletonStatusNone){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [self gkSkeleton_tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end
