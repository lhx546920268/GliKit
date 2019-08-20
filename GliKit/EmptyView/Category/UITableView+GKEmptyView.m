//
//  UITableView+CAEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UITableView+CAEmptyView.h"
#import <objc/runtime.h>
#import "UIView+CAEmptyView.h"
#import "UIScrollView+CAEmptyView.h"

static char CAShouldShowEmptyViewWhenExistTableHeaderViewKey;
static char CAShouldShowEmptyViewWhenExistTableFooterViewKey;
static char CAShouldShowEmptyViewWhenExistSectionHeaderViewKey;
static char CAShouldShowEmptyViewWhenExistSectionFooterViewKey;

@implementation UITableView (CAEmptyView)

#pragma mark- super method

- (void)layoutEmtpyView
{
    [super layoutEmtpyView];
    
    GKEmptyView *emptyView = self.ca_emptyView;
    if(emptyView && emptyView.superview && !emptyView.hidden){
        CGRect frame = emptyView.frame;
        CGFloat y = frame.origin.y;
        
        y += self.tableHeaderView.mj_h;
        y += self.tableFooterView.mj_h;
        
        NSInteger numberOfSections = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
            numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
        }
        
        ///获取sectionHeader 高度
        if(self.ca_shouldShowEmptyViewWhenExistSectionHeaderView){
            if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForHeaderInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionHeaderHeight;
            }
        }
        
        ///获取section footer 高度
        if(self.ca_shouldShowEmptyViewWhenExistTableFooterView){
            if([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForFooterInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionFooterHeight;
            }
        }
        
        frame.origin.y = y;
        frame.size.height = self.mj_h - y;
        if(frame.size.height <= 0){
            [emptyView removeFromSuperview];
        }else{
            emptyView.frame = frame;
        }
    }
}

- (BOOL)isEmptyData
{
    BOOL empty = YES;
    
    if(!self.ca_shouldShowEmptyViewWhenExistTableHeaderView && self.tableHeaderView){
        empty = NO;
    }
    
    if(!self.ca_shouldShowEmptyViewWhenExistTableFooterView && self.tableFooterView){
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
            if(!self.ca_shouldShowEmptyViewWhenExistSectionHeaderView && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.delegate tableView:self viewForHeaderInSection:i];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
            
            if(empty && !self.ca_shouldShowEmptyViewWhenExistSectionFooterView && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
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

#pragma mark- property

- (void)setCa_shouldShowEmptyViewWhenExistTableHeaderView:(BOOL)ca_shouldShowEmptyViewWhenExistTableHeaderView
{
    objc_setAssociatedObject(self, &CAShouldShowEmptyViewWhenExistTableHeaderViewKey, [NSNumber numberWithBool:ca_shouldShowEmptyViewWhenExistTableHeaderView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ca_shouldShowEmptyViewWhenExistTableHeaderView
{
    NSNumber *number = objc_getAssociatedObject(self, &CAShouldShowEmptyViewWhenExistTableHeaderViewKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}

- (void)setCa_shouldShowEmptyViewWhenExistTableFooterView:(BOOL)ca_shouldShowEmptyViewWhenExistTableFooterView
{
    objc_setAssociatedObject(self, &CAShouldShowEmptyViewWhenExistTableFooterViewKey, [NSNumber numberWithBool:ca_shouldShowEmptyViewWhenExistTableFooterView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ca_shouldShowEmptyViewWhenExistTableFooterView
{
    NSNumber *number = objc_getAssociatedObject(self, &CAShouldShowEmptyViewWhenExistTableFooterViewKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}


- (void)setCa_shouldShowEmptyViewWhenExistSectionHeaderView:(BOOL)ca_shouldShowEmptyViewWhenExistSectionHeaderView
{
    objc_setAssociatedObject(self, &CAShouldShowEmptyViewWhenExistSectionHeaderViewKey, [NSNumber numberWithBool:ca_shouldShowEmptyViewWhenExistSectionHeaderView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ca_shouldShowEmptyViewWhenExistSectionHeaderView
{
    NSNumber *number = objc_getAssociatedObject(self, &CAShouldShowEmptyViewWhenExistSectionHeaderViewKey);
    if(number){
        return [number boolValue];
    }
    
    return NO;
}


- (void)setCa_shouldShowEmptyViewWhenExistSectionFooterView:(BOOL)ca_shouldShowEmptyViewWhenExistSectionFooterView
{
    objc_setAssociatedObject(self, &CAShouldShowEmptyViewWhenExistSectionFooterViewKey, [NSNumber numberWithBool:ca_shouldShowEmptyViewWhenExistSectionFooterView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ca_shouldShowEmptyViewWhenExistSectionFooterView
{
    NSNumber *number = objc_getAssociatedObject(self, &CAShouldShowEmptyViewWhenExistSectionFooterViewKey);
    if(number)
    {
        return [number boolValue];
    }
    
    return NO;
}

#pragma mark- swizzle

+ (void)load
{
    SEL selectors[] = {
        
        @selector(reloadData),
        @selector(reloadSections:withRowAnimation:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(layoutSubviews) //使用约束时 frame会在layoutSubviews得到
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(NSInteger i = 0;i < count;i ++)
    {
        SEL selector1 = selectors[i];
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"ca_empty_%@", NSStringFromSelector(selector1)]);
        
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

- (void)ca_empty_reloadData
{
    [self ca_empty_reloadData];
    [self layoutEmtpyView];
}

- (void)ca_empty_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self ca_empty_reloadSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)ca_empty_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self ca_empty_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)ca_empty_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self ca_empty_insertSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)ca_empty_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self ca_empty_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self layoutEmtpyView];
}

- (void)ca_empty_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self ca_empty_deleteSections:sections withRowAnimation:animation];
    [self layoutEmtpyView];
}

///用于使用约束时没那么快得到 frame
- (void)ca_empty_layoutSubviews
{
    [self ca_empty_layoutSubviews];
    if(!CGSizeEqualToSize(self.ca_oldSize, self.frame.size)){
        self.ca_oldSize = self.frame.size;
        [self layoutEmtpyView];
    }
}


@end
