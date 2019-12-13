//
//  UITableView+GKEmptyView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UITableView+GKEmptyView.h"
#import <objc/runtime.h>
#import "UIView+GKEmptyView.h"
#import "UIScrollView+GKEmptyView.h"
#import "UIView+GKUtils.h"

static char GKShouldShowEmptyViewWhenExistTableHeaderKey;
static char GKShouldShowEmptyViewWhenExistTableFooterKey;
static char GKShouldShowEmptyViewWhenExistSectionHeaderKey;
static char GKShouldShowEmptyViewWhenExistTableHeaderKey;

@implementation UITableView (GKEmptyView)

// MARK: - Super Method

- (void)layoutEmtpyView
{
    [super layoutEmtpyView];
    
    GKEmptyView *emptyView = self.gkEmptyView;
    if(emptyView && emptyView.superview && !emptyView.hidden){
        CGRect frame = emptyView.frame;
        CGFloat y = frame.origin.y;
        
        y += self.tableHeaderView.gkHeight;
        y += self.tableFooterView.gkHeight;
        
        NSInteger numberOfSections = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
            numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
        }
        
        ///获取sectionHeader 高度
        if(self.gkShouldShowEmptyViewWhenExistSectionHeader){
            if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForHeaderInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionHeaderHeight;
            }
        }
        
        ///获取section footer 高度
        if(self.gkShouldShowEmptyViewWhenExistTableFooter){
            if([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForFooterInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionFooterHeight;
            }
        }
        
        frame.origin.y = y;
        frame.size.height -= y;
        if(frame.size.height <= 0){
            [emptyView removeFromSuperview];
        }else{
            emptyView.frame = frame;
        }
    }
}

- (BOOL)gkIsEmptyData
{
    BOOL empty = YES;
    
    if(!self.gkShouldShowEmptyViewWhenExistTableHeader && self.tableHeaderView){
        empty = NO;
    }
    
    if(!self.gkShouldShowEmptyViewWhenExistTableFooter && self.tableFooterView){
        empty = NO;
    }
    
    if(empty && self.dataSource){
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
            section = [self.dataSource numberOfSectionsInTableView:self];
        }
        
        if([self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]){
            for(NSInteger i = 0;i < section;i ++){
                NSInteger row = [self.dataSource tableView:self numberOfRowsInSection:i];
                if(row > 0){
                    empty = NO;
                    break;
                }
            }
        }
        
        ///行数为0，section 大于0时，可能存在sectionHeader
        if(empty && section > 0 && self.delegate){
            if(!self.gkShouldShowEmptyViewWhenExistSectionHeader && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.delegate tableView:self viewForHeaderInSection:i];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
            
            if(empty && !self.gkShouldShowEmptyViewWhenExistSectionFooter && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.delegate tableView:self viewForFooterInSection:i];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
        }
    }
    
    return empty;
}

// MARK: - Property

- (void)setGkShouldShowEmptyViewWhenExistTableHeader:(BOOL) header
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderKey, @(header), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistTableHeader
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}

- (void)setGkShouldShowEmptyViewWhenExistTableFooter:(BOOL) footer
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableFooterKey, @(footer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistTableFooter
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableFooterKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}


- (void)setGkShouldShowEmptyViewWhenExistSectionHeader:(BOOL) header
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionHeaderKey, @(header), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistSectionHeader
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionHeaderKey);
    if(number){
        return [number boolValue];
    }
    
    return NO;
}


- (void)setGkShouldShowEmptyViewWhenExistSectionFooter:(BOOL) footer
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderKey,@(footer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistSectionFooter
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderKey);
    if(number)
    {
        return [number boolValue];
    }
    
    return NO;
}

// MARK: - Swizzle

+ (void)load
{
    SEL selectors[] = {
        
        @selector(reloadData),
        @selector(reloadSections:withRowAnimation:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(NSInteger i = 0;i < count;i ++)
    {
        SEL selector1 = selectors[i];
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkEmpty_%@", NSStringFromSelector(selector1)]);
        
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

- (void)gkEmpty_reloadData
{
    [self gkEmpty_reloadData];
    [self layoutEmtpyView];
}

- (void)gkEmpty_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self gkEmpty_reloadSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)gkEmpty_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self gkEmpty_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)gkEmpty_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self gkEmpty_insertSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)gkEmpty_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self gkEmpty_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)gkEmpty_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self gkEmpty_deleteSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

@end
