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

static char GKShouldIgnoreTableHeaderKey;
static char GKShouldIgnoreTableFooterKey;
static char GKShouldIgnoreSectionHeaderKey;
static char GKShouldIgnoreTableHeaderKey;

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
        if(self.gkShouldIgnoreSectionHeader){
            if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]){
                for(NSInteger i = 0;i < numberOfSections;i ++){
                    y += [self.delegate tableView:self heightForHeaderInSection:i];
                }
            }else{
                y += numberOfSections * self.sectionHeaderHeight;
            }
        }
        
        ///获取section footer 高度
        if(self.gkShouldIgnoreSectionFooter){
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
    
    if(!self.gkShouldIgnoreTableHeader && self.tableHeaderView){
        empty = NO;
    } else if(!self.gkShouldIgnoreTableFooter && self.tableFooterView){
        empty = NO;
    } else if(self.dataSource){
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]){
            section = [self.dataSource numberOfSectionsInTableView:self];
        }
        
        if(section > 0){
            for(NSInteger i = 0;i < section;i ++){
                NSInteger row = [self.dataSource tableView:self numberOfRowsInSection:i];
                if(row > 0){
                    empty = NO;
                    break;
                }
            }
            
            ///行数为0，section 大于0时，可能存在sectionHeader
            if(empty && section > 0 && self.delegate){
                if(!self.gkShouldIgnoreSectionHeader && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]){
                    for(NSInteger i = 0; i < section;i ++){
                        UIView *view = [self.delegate tableView:self viewForHeaderInSection:i];
                        if(view){
                            empty = NO;
                            break;
                        }
                    }
                }
                
                if(empty && !self.gkShouldIgnoreSectionFooter && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]){
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
    }
    
    return empty;
}

// MARK: - Property

- (void)setGkShouldIgnoreTableHeader:(BOOL) ignore
{
    objc_setAssociatedObject(self, &GKShouldIgnoreTableHeaderKey, @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldIgnoreTableHeader
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldIgnoreTableHeaderKey);
    if(number != nil){
        return [number boolValue];
    }
    
    return YES;
}

- (void)setGkShouldIgnoreTableFooter:(BOOL) ignore
{
    objc_setAssociatedObject(self, &GKShouldIgnoreTableFooterKey, @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldIgnoreTableFooter
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldIgnoreTableFooterKey);
    if(number != nil){
        return [number boolValue];
    }
    
    return YES;
}


- (void)setGkShouldIgnoreSectionHeader:(BOOL) ignore
{
    objc_setAssociatedObject(self, &GKShouldIgnoreSectionHeaderKey, @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldIgnoreSectionHeader
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldIgnoreSectionHeaderKey);
    if(number != nil){
        return [number boolValue];
    }
    
    return NO;
}


- (void)setGkShouldIgnoreSectionFooter:(BOOL) ignore
{
    objc_setAssociatedObject(self, &GKShouldIgnoreTableHeaderKey,@(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldIgnoreSectionFooter
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldIgnoreTableHeaderKey);
    if(number != nil){
        return [number boolValue];
    }
    
    return NO;
}

@end
