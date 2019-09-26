//
//  UITableView+GKRowHeight.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UITableView+GKRowHeight.h"
#import <objc/runtime.h>

///tableView section 缓存大小
@interface GKTableViewSectionInfo : NSObject

///header 高度
@property(nonatomic, strong) NSNumber *headerHeight;

///footer高度
@property(nonatomic, strong) NSNumber *footerHeight;

///行高
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, NSNumber*> *rowHeights;

@end

@implementation GKTableViewSectionInfo

- (instancetype)init
{
    self = [super init];
    if(self){
        self.rowHeights = [NSMutableDictionary dictionary];
    }
    
    return self;
}

@end

@implementation UITableView (GKRowHeight)

+ (void)load
{
    SEL selectors[] = {
        
        @selector(reloadData),
        @selector(reloadSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:),
    };
    
    
    for(NSInteger i = 0;i < sizeof(selectors) / sizeof(SEL);i ++){
        SEL selector1 = selectors[i];
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkRowHeight_%@", NSStringFromSelector(selector1)]);
        
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

// MARK: - - data change

- (void)gkRowHeight_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gkRowHeight_reloadSections:sections withRowAnimation:animation];
}

- (void)gkRowHeight_deleteSections:(NSIndexSet *) sections withRowAnimation:(UITableViewRowAnimation)animation
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gkRowHeight_deleteSections:sections withRowAnimation:animation];
}

- (void)gkRowHeight_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        
        GKTableViewSectionInfo *info = [caches objectForKey:@(section)];
        GKTableViewSectionInfo *newInfo = [caches objectForKey:@(newSection)];
        
        if(info != nil && newInfo != nil){
            [caches setObject:info forKey:@(newSection)];
            [caches setObject:newInfo forKey:@(section)];
        }else if(info != nil){
            [caches setObject:info forKey:@(newSection)];
        }else if (newInfo != nil){
            [caches setObject:newInfo forKey:@(section)];
        }
    }
    
    [self gkRowHeight_moveSection:section toSection:newSection];
}

- (void)gkRowHeight_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        NSNumber *number = [self gkRowHeightForIndexPath:indexPath];
        NSNumber *toNumber = [self gkRowHeightForIndexPath:newIndexPath];
        
        if(number != nil && toNumber != nil){
            [self gkSetRowHeight:number forIndexPath:indexPath];
            [self gkSetRowHeight:toNumber forIndexPath:newIndexPath];
        }else if(number != nil){
            [self gkSetRowHeight:number forIndexPath:indexPath];
        }else if (toNumber != nil){
            [self gkSetRowHeight:toNumber forIndexPath:newIndexPath];
        }
    }
    
    [self gkRowHeight_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)gkRowHeight_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gkSetRowHeight:nil forIndexPath:indexPath];
        }
    }
    
    [self gkRowHeight_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)gkRowHeight_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gkSetRowHeight:nil forIndexPath:indexPath];
        }
    }
    
    [self gkRowHeight_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}


- (void)gkRowHeight_reloadData
{
    [[self gk_rowHeightCaches] removeAllObjects];
    [self gkRowHeight_reloadData];
}

// MARK: - get and set

- (NSNumber*)gkRowHeightForIndexPath:(NSIndexPath *)indexPath
{
    GKTableViewSectionInfo *info = [self gk_sectionInfoForSection:indexPath.section];
    return info.rowHeights ? info.rowHeights[@(indexPath.row)] : nil;
}

- (void)gkSetRowHeight:(NSNumber *)rowHeight forIndexPath:(NSIndexPath *)indexPath
{
    GKTableViewSectionInfo *info = [self gk_sectionInfoForSection:indexPath.section];
    
    if(rowHeight != nil){
        [info.rowHeights setObject:rowHeight forKey:@(indexPath.row)];
    }else{
        [info.rowHeights removeObjectForKey:@(indexPath.row)];
    }
}

- (void)gkSetHeaderHeight:(NSNumber*) height forSection:(NSInteger) section
{
    GKTableViewSectionInfo *info = [self gk_sectionInfoForSection:section];
    info.headerHeight = height;
}

- (NSNumber*)gkHeaderHeightForSection:(NSInteger) section
{
    GKTableViewSectionInfo *info = [[self gk_rowHeightCaches] objectForKey:@(section)];
    return info.headerHeight;
}

- (void)gkSetFooterHeight:(NSNumber*) height forSection:(NSInteger) section
{
    GKTableViewSectionInfo *info = [self gk_sectionInfoForSection:section];
    info.footerHeight = height;
}

- (NSNumber*)gkFooterHeightForSection:(NSInteger) section
{
    GKTableViewSectionInfo *info = [[self gk_rowHeightCaches] objectForKey:@(section)];
    return info.footerHeight;
}

// MARK: - cell大小缓存

///缓存cell大小的数组
- (NSMutableDictionary<NSNumber*, GKTableViewSectionInfo* >*)gk_rowHeightCaches
{
    NSMutableDictionary *caches = objc_getAssociatedObject(self, _cmd);
    if(caches == nil){
        caches = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, caches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return caches;
}

///设置缓存
- (GKTableViewSectionInfo*)gk_sectionInfoForSection:(NSInteger) section
{
    NSMutableDictionary *caches = [self gk_rowHeightCaches];
    GKTableViewSectionInfo *info = [caches objectForKey:@(section)];
    if(info == nil)
    {
        info = [GKTableViewSectionInfo new];
        [caches setObject:info forKey:@(section)];
    }
    return info;
}

@end
