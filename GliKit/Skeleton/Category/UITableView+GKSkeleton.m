//
//  UITableView+GKSkeleton.m
//  IOSLibrary
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UITableView+GKSkeleton.h"
#import <NSObject+Utils.h>
#import "UIView+GKSkeleton.h"
#import <objc/runtime.h>
#import "GKSkeletonHelper.h"

static char GKSkeletonHideAnimateKey;

@implementation UITableView (GKSkeleton)

+ (void)load
{
    [self gk_exchangeImplementations:@selector(setDelegate:) prefix:@"gk_skeleton_"];
    [self gk_exchangeImplementations:@selector(setDataSource:) prefix:@"gk_skeleton_"];
}

- (void)gk_skeleton_setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegate){
        [GKSkeletonHelper replaceImplementations:@selector(tableView:didSelectRowAtIndexPath:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:viewForHeaderInSection:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:viewForFooterInSection:) owner:delegate implementer:self];
        [GKSkeletonHelper replaceImplementations:@selector(tableView:shouldHighlightRowAtIndexPath:) owner:delegate implementer:self];
    }
    
    [self gk_skeleton_setDelegate:delegate];
}

- (void)gk_skeleton_setDataSource:(id<UITableViewDataSource>)dataSource
{
    if(dataSource){
        [GKSkeletonHelper replaceImplementations:@selector(tableView:cellForRowAtIndexPath:) owner:dataSource implementer:self];
    }
    
    [self gk_skeleton_setDataSource:dataSource];
}

- (void)gk_showSkeletonWithDuration:(NSTimeInterval)duration completion:(GKShowSkeletonCompletionHandler)completion
{
    if(self.gk_skeletonStatus == GKSkeletonStatusNone){
        self.gk_skeletonStatus = GKSkeletonStatusShowing;
        [self reloadData];
        
        if(duration > 0 && completion){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }
}

- (void)setGk_skeletonHideAnimate:(BOOL) animate
{
    objc_setAssociatedObject(self, &GKSkeletonHideAnimateKey, @(animate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_skeletonHideAnimate
{
    return [objc_getAssociatedObject(self, &GKSkeletonHideAnimateKey) boolValue];
}

- (void)gk_hideSkeletonWithAnimate:(BOOL)animate completion:(void (^)(BOOL))completion
{
    GKSkeletonStatus status = self.gk_skeletonStatus;
    if(status == GKSkeletonStatusShowing){
        self.gk_skeletonStatus = GKSkeletonStatusWillHide;
        [self setGk_skeletonHideAnimate:animate];
        [self reloadData];
    }
}

//MARK: UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.gk_skeletonStatus == GKSkeletonStatusNone;
}

- (BOOL)gk_skeleton_tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.gk_skeletonStatus != GKSkeletonStatusNone){
        return NO;
    }
    
    return [self gk_skeleton_tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}

- (UIView*)gk_skeleton_tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [self gk_skeleton_tableView:tableView viewForFooterInSection:section];
    
    GKSkeletonStatus status = tableView.gk_skeletonStatus;
    switch (status) {
        case GKSkeletonStatusShowing : {
            
            [view gk_showSkeleton];
        }
            break;
        case GKSkeletonStatusWillHide: {
            
            __weak UITableView *weakSelf = tableView;
            [view gk_hideSkeletonWithAnimate:tableView.gk_skeletonHideAnimate completion:^(BOOL finished) {
                if(weakSelf.gk_skeletonStatus == GKSkeletonStatusWillHide){
                    weakSelf.gk_skeletonLayer = nil;
                }
            }];
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (UIView*)gk_skeleton_tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [self gk_skeleton_tableView:tableView viewForHeaderInSection:section];
    
    GKSkeletonStatus status = tableView.gk_skeletonStatus;
    switch (status) {
        case GKSkeletonStatusShowing : {
            
            [view gk_showSkeleton];
        }
            break;
        case GKSkeletonStatusWillHide: {
            
            __weak UITableView *weakSelf = tableView;
            [view gk_hideSkeletonWithAnimate:tableView.gk_skeletonHideAnimate completion:^(BOOL finished) {
                if(weakSelf.gk_skeletonStatus == GKSkeletonStatusWillHide){
                    weakSelf.gk_skeletonLayer = nil;
                }
            }];
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (UITableViewCell*)gk_skeleton_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self gk_skeleton_tableView:tableView cellForRowAtIndexPath:indexPath];
    
    GKSkeletonStatus status = tableView.gk_skeletonStatus;
    switch (status) {
        case GKSkeletonStatusShowing : {
            
            [cell.contentView gk_showSkeleton];
        }
            break;
        case GKSkeletonStatusWillHide: {
            
            __weak UITableView *weakSelf = tableView;
            [cell.contentView gk_hideSkeletonWithAnimate:tableView.gk_skeletonHideAnimate completion:^(BOOL finished) {
                if(weakSelf.gk_skeletonStatus == GKSkeletonStatusWillHide){
                    weakSelf.gk_skeletonLayer = nil;
                }
            }];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)gk_skeleton_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.gk_skeletonStatus != GKSkeletonStatusNone){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [self gk_skeleton_tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end
