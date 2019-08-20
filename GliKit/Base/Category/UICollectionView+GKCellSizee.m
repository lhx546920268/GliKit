//
//  UICollectionView+GKCellSize.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UICollectionView+GKCellSize.h"
#import <objc/runtime.h>
#import "UIView+GKAutoLayout.h"

@implementation UICollectionView (GKCellSize)

+ (void)load {
    SEL selectors[] = {
        
        @selector(reloadData),
        @selector(reloadSections:),
        @selector(deleteSections:),
        @selector(moveSection:toSection:),
        @selector(reloadItemsAtIndexPaths:),
        @selector(deleteItemsAtIndexPaths:),
        @selector(moveItemAtIndexPath:toIndexPath:),
        
        @selector(registerNib:forCellWithReuseIdentifier:),
        @selector(registerClass:forCellWithReuseIdentifier:),
        @selector(registerNib:forSupplementaryViewOfKind:withReuseIdentifier:),
        @selector(registerClass:forSupplementaryViewOfKind:withReuseIdentifier:),
    };
    
    for(NSInteger i = 0;i < sizeof(selectors) / sizeof(SEL);i ++){
        
        SEL selector1 = selectors[i];
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gk_cellSize_%@", NSStringFromSelector(selector1)]);
        
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

#pragma mark - register cells

- (void)gk_cellSize_registerClass:(Class) clazz forCellWithReuseIdentifier:(NSString *) identifier
{
    [self gk_cellSize_registerClass:clazz forCellWithReuseIdentifier:identifier];
    [[self gk_registerObjects] setObject:NSStringFromClass(clazz) forKey:identifier];
}

- (void)gk_cellSize_registerNib:(UINib *) nib forCellWithReuseIdentifier:(NSString *) identifier
{
    [self gk_cellSize_registerNib:nib forCellWithReuseIdentifier:identifier];
    [[self gk_registerObjects] setObject:nib forKey:identifier];
}

- (void)gk_cellSize_registerClass:(Class) clazz forSupplementaryViewOfKind:(NSString *) kind withReuseIdentifier:(NSString *)identifier
{
    [self gk_cellSize_registerClass:clazz forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    [[self gk_registerObjects] setObject:NSStringFromClass(clazz) forKey:identifier];
}

- (void)gk_cellSize_registerNib:(UINib *) nib forSupplementaryViewOfKind:(NSString *) kind withReuseIdentifier:(NSString *)identifier
{
    [self gk_cellSize_registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    [[self gk_registerObjects] setObject:nib forKey:identifier];
}

#pragma mark - data change

- (void)gk_cellSize_reloadSections:(NSIndexSet *) sections
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0)    {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gk_cellSize_reloadSections:sections];
}

- (void)gk_cellSize_deleteSections:(NSIndexSet *) sections
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0){
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gk_cellSize_deleteSections:sections];
}

- (void)gk_cellSize_moveSection:(NSInteger) section toSection:(NSInteger) newSection
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0){
        NSMutableDictionary *dic = [caches objectForKey:@(section)];
        NSMutableDictionary *newDic = [caches objectForKey:@(newSection)];
        
        if(dic != nil && newDic != nil){
            [caches setObject:dic forKey:@(newSection)];
            [caches setObject:newDic forKey:@(section)];
        }else if(dic != nil){
            [caches setObject:dic forKey:@(newSection)];
        }else if (newDic != nil){
            [caches setObject:newDic forKey:@(section)];
        }
    }
    
    [self gk_cellSize_moveSection:section toSection:newSection];
}

- (void)gk_cellSize_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *) newIndexPath
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0){
        NSValue *value = [self gk_cachedSizeForIndexPath:indexPath];
        NSValue *toValue = [self gk_cachedSizeForIndexPath:newIndexPath];
        
        if(value != nil && toValue != nil){
            [self gk_setCellSize:value forIndexPath:indexPath];
            [self gk_setCellSize:toValue forIndexPath:newIndexPath];
        }else if(value != nil){
            [self gk_setCellSize:value forIndexPath:indexPath];
        }else if (toValue != nil){
            [self gk_setCellSize:toValue forIndexPath:newIndexPath];
        }
    }
    
    [self gk_cellSize_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)gk_cellSize_deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gk_setCellSize:nil forIndexPath:indexPath];
        }
    }
    
    [self gk_cellSize_deleteItemsAtIndexPaths:indexPaths];
}

- (void)gk_cellSize_reloadItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gk_setCellSize:nil forIndexPath:indexPath];
        }
    }
    
    [self gk_cellSize_reloadItemsAtIndexPaths:indexPaths];
}



- (void)gk_cellSize_reloadData
{
    [[self gk_cellSizeCaches] removeAllObjects];
    [self gk_cellSize_reloadData];
}

#pragma mark- 计算

- (CGSize)gk_cellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath configuration:(GKCellConfiguration) configuration
{
    return [self gk_cellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeZero configuration:configuration];
}

- (CGSize)gk_cellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath constraintSize:(CGSize) constraintSize configuration:(GKCellConfiguration) configuration
{
    return [self gk_cellSizeForIdentifier:identifier indexPath:indexPath constraintSize:constraintSize type:GKAutoLayoutCalculateTypeSize configuration:configuration];
}

- (CGSize)gk_cellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath width:(CGFloat) width configuration:(GKCellConfiguration) configuration
{
    return [self gk_cellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeMake(width, 0) type:GKAutoLayoutCalculateTypeHeight configuration:configuration];
}

- (CGSize)gk_cellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath height:(CGFloat) height configuration:(GKCellConfiguration) configuration
{
    return [self gk_cellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeMake(0, height) type:GKAutoLayoutCalculateTypeWidth configuration:configuration];
}

- (CGSize)gk_cellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath constraintSize:(CGSize) constraintSize type:(GKAutoLayoutCalculateType) type configuration:(GKCellConfiguration) configuration
{
    NSValue *value = [self gk_cachedSizeForIndexPath:indexPath];
    if (value != nil && !CGSizeEqualToSize(CGSizeZero, [value CGSizeValue])){
        return [value CGSizeValue];
    }
    
    //计算大小
    UICollectionReusableView *cell = [self gk_cellForIdentifier:identifier];
    !configuration ?: configuration(cell);
    
    UIView *contentView = cell;
    if([cell isKindOfClass:[UICollectionViewCell class]]){
        contentView = [(UICollectionViewCell*)cell contentView];
    }
    CGSize size = [contentView gk_sizeThatFits:constraintSize type:type];
    
    [self gk_setCellSize:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    
    return size;
}


#pragma mark - cell大小缓存

///缓存cell大小的数组
- (NSMutableDictionary<NSNumber*, NSMutableDictionary<NSNumber*, NSValue*>* >*)gk_cellSizeCaches
{
    NSMutableDictionary *caches = objc_getAssociatedObject(self, _cmd);
    if(caches == nil){
        caches = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, caches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return caches;
}

///判断是否已有缓存
- (NSValue*)gk_cachedSizeForIndexPath:(NSIndexPath*) indexPath
{
    NSMutableDictionary *dic = [[self gk_cellSizeCaches] objectForKey:@(indexPath.section)];
    if(dic == nil)
        return nil;
    return [dic objectForKey:@(indexPath.item)];
}

///设置缓存
- (void)gk_setCellSize:(NSValue*) size forIndexPath:(NSIndexPath*) indexPath
{
    NSMutableDictionary *caches = [self gk_cellSizeCaches];
    NSMutableDictionary *dic = [caches objectForKey:@(indexPath.section)];
    if(dic == nil){
        dic = [NSMutableDictionary dictionary];
        [caches setObject:dic forKey:@(indexPath.section)];
    }
    
    if(size != nil){
        [dic setObject:size forKey:@(indexPath.item)];
    }else{
        [dic removeObjectForKey:@(indexPath.item)];
    }
}

#pragma mark- 注册的 cells

///注册的 class nib
- (NSMutableDictionary*)gk_registerObjects
{
    NSMutableDictionary *objects = objc_getAssociatedObject(self, _cmd);
    if (objects == nil){
        objects = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, objects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objects;
}

///注册的cells header footer 用来计算
- (__kindof UICollectionReusableView*)gk_cellForIdentifier:(NSString *)identifier
{
    NSAssert(identifier != nil, @"identifier 不能为 nil");
    
    NSMutableDictionary<NSString*, UICollectionReusableView*> *cells = objc_getAssociatedObject(self, _cmd);
    if (cells == nil){
        cells = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UICollectionReusableView *view = [cells objectForKey:identifier];
    if(view == nil){
        NSObject *obj = [[self gk_registerObjects] objectForKey:identifier];
        if([obj isKindOfClass:[UINib class]]){
            UINib *nib = (UINib*)obj;
            view = [[nib instantiateWithOwner:nil options:nil] firstObject];
            [cells setObject:view forKey:identifier];
        }else if([obj isKindOfClass:[NSString class]]){
            Class clazz = NSClassFromString((NSString*)obj);
            view = [clazz new];
            [cells setObject:view forKey:identifier];
        }
    }
    
    NSAssert(view != nil, @"必须注册 %@ 对应的 cell header footer", identifier);
    
    return view;
}


///头部
- (NSIndexPath*)gk_headerIndexPathForSection:(NSInteger) section
{
    return [NSIndexPath indexPathForItem:-1 inSection:section];
}

///底部
- (NSIndexPath*)gk_footerIndexPathForSection:(NSInteger) section
{
    return [NSIndexPath indexPathForItem:-2 inSection:section];
}

@end
