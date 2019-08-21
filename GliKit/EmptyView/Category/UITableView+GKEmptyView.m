//
//  UITableView+GKEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UITableView+GKEmptyView.h"
#import <objc/runtime.h>
#import "UIView+GKEmptyView.h"
#import "UIScrollView+GKEmptyView.h"
#import "UIView+GKUtils.h"

static char GKShouldShowEmptyViewWhenExistTableHeaderViewKey;
static char GKShouldShowEmptyViewWhenExistTableFooterViewKey;
static char GKShouldShowEmptyViewWhenExistSectionHeaderViewKey;
static char GKShouldShowEmptyViewWhenExistSectionFooterViewKey;

@implementation UITableView (GKEmptyView)

//MARK: Super Method

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
        if(self.gkShouldShowEmptyViewWhenExistSectionHeaderView){
            if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForHeaderInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionHeaderHeight;
            }
        }
        
        ///获取section footer 高度
        if(self.gkShouldShowEmptyViewWhenExistTableFooterView){
            if([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForFooterInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionFooterHeight;
            }
        }
        
        frame.origin.y = y;
        frame.size.height = self.gkHeight - y;
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
    
    if(!self.gkShouldShowEmptyViewWhenExistTableHeaderView && self.tableHeaderView){
        empty = NO;
    }
    
    if(!self.gkShouldShowEmptyViewWhenExistTableFooterView && self.tableFooterView){
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
            if(!self.gkShouldShowEmptyViewWhenExistSectionHeaderView && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.delegate tableView:self viewForHeaderInSection:i];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
            
            if(empty && !self.gkShouldShowEmptyViewWhenExistSectionFooterView && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
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

//MARK: Property

- (void)setGkShouldShowEmptyViewWhenExistTableHeaderView:(BOOL)gkShouldShowEmptyViewWhenExistTableHeaderView
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderViewKey, @(gkShouldShowEmptyViewWhenExistTableHeaderView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistTableHeaderView
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableHeaderViewKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}

- (void)setGkShouldShowEmptyViewWhenExistTableFooterView:(BOOL)gkShouldShowEmptyViewWhenExistTableFooterView
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableFooterViewKey, @(gkShouldShowEmptyViewWhenExistTableFooterView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistTableFooterView
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistTableFooterViewKey);
    if(number){
        return [number boolValue];
    }
    
    return YES;
}


- (void)setGkShouldShowEmptyViewWhenExistSectionHeaderView:(BOOL)gkShouldShowEmptyViewWhenExistSectionHeaderView
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionHeaderViewKey, @(gkShouldShowEmptyViewWhenExistSectionHeaderView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistSectionHeaderView
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionHeaderViewKey);
    if(number){
        return [number boolValue];
    }
    
    return NO;
}


- (void)setGkShouldShowEmptyViewWhenExistSectionFooterView:(BOOL)gkShouldShowEmptyViewWhenExistSectionFooterView
{
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionFooterViewKey,@(gkShouldShowEmptyViewWhenExistSectionFooterView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistSectionFooterView
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionFooterViewKey);
    if(number)
    {
        return [number boolValue];
    }
    
    return NO;
}

//MARK: Swizzle

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

///用于使用约束时没那么快得到 frame
- (void)gkEmpty_layoutSubviews
{
    [self gkEmpty_layoutSubviews];
    if(!CGSizeEqualToSize(self.gkOldSize, self.frame.size)){
        self.gkOldSize = self.frame.size;
        [self layoutEmtpyView];
    }
}


@end
