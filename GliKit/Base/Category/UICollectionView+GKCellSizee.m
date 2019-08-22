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
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkCellSize_%@", NSStringFromSelector(selector1)]);
        
        Method method1 = class_getInstanceMethod(self, selector1);
        Method method2 = class_getInstanceMethod(self, selector2);
        
        method_exchangeImplementations(method1, method2);
    }
}

//MARK: register cells

- (void)gkCellSize_registerClass:(Class) clazz forCellWithReuseIdentifier:(NSString *) identifier
{
    [self gkCellSize_registerClass:clazz forCellWithReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:NSStringFromClass(clazz) forKey:identifier];
}

- (void)gkCellSize_registerNib:(UINib *) nib forCellWithReuseIdentifier:(NSString *) identifier
{
    [self gkCellSize_registerNib:nib forCellWithReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:nib forKey:identifier];
}

- (void)gkCellSize_registerClass:(Class) clazz forSupplementaryViewOfKind:(NSString *) kind withReuseIdentifier:(NSString *)identifier
{
    [self gkCellSize_registerClass:clazz forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:NSStringFromClass(clazz) forKey:identifier];
}

- (void)gkCellSize_registerNib:(UINib *) nib forSupplementaryViewOfKind:(NSString *) kind withReuseIdentifier:(NSString *)identifier
{
    [self gkCellSize_registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:nib forKey:identifier];
}

//MARK: data change

- (void)gkCellSize_reloadSections:(NSIndexSet *) sections
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
    if(caches.count > 0)    {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gkCellSize_reloadSections:sections];
}

- (void)gkCellSize_deleteSections:(NSIndexSet *) sections
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
    if(caches.count > 0){
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            
            [caches removeObjectForKey:@(section)];
        }];
    }
    [self gkCellSize_deleteSections:sections];
}

- (void)gkCellSize_moveSection:(NSInteger) section toSection:(NSInteger) newSection
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
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
    
    [self gkCellSize_moveSection:section toSection:newSection];
}

- (void)gkCellSize_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *) newIndexPath
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
    if(caches.count > 0){
        NSValue *value = [self gkCachedSizeForIndexPath:indexPath];
        NSValue *toValue = [self gkCachedSizeForIndexPath:newIndexPath];
        
        if(value != nil && toValue != nil){
            [self gkSetCellSize:value forIndexPath:indexPath];
            [self gkSetCellSize:toValue forIndexPath:newIndexPath];
        }else if(value != nil){
            [self gkSetCellSize:value forIndexPath:indexPath];
        }else if (toValue != nil){
            [self gkSetCellSize:toValue forIndexPath:newIndexPath];
        }
    }
    
    [self gkCellSize_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)gkCellSize_deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gkSetCellSize:nil forIndexPath:indexPath];
        }
    }
    
    [self gkCellSize_deleteItemsAtIndexPaths:indexPaths];
}

- (void)gkCellSize_reloadItemsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
    if(caches.count > 0){
        for(NSIndexPath *indexPath in indexPaths){
            [self gkSetCellSize:nil forIndexPath:indexPath];
        }
    }
    
    [self gkCellSize_reloadItemsAtIndexPaths:indexPaths];
}



- (void)gkCellSize_reloadData
{
    [[self gkCellSizeCaches] removeAllObjects];
    [self gkCellSize_reloadData];
}

//MARK:- 计算

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath configuration:(GKCellConfiguration) configuration
{
    return [self gkCellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeZero configuration:configuration];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath constraintSize:(CGSize) constraintSize configuration:(GKCellConfiguration) configuration
{
    return [self gkCellSizeForIdentifier:identifier indexPath:indexPath constraintSize:constraintSize type:GKAutoLayoutCalculateTypeSize configuration:configuration];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath width:(CGFloat) width configuration:(GKCellConfiguration) configuration
{
    return [self gkCellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeMake(width, 0) type:GKAutoLayoutCalculateTypeHeight configuration:configuration];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath height:(CGFloat) height configuration:(GKCellConfiguration) configuration
{
    return [self gkCellSizeForIdentifier:identifier indexPath:indexPath constraintSize:CGSizeMake(0, height) type:GKAutoLayoutCalculateTypeWidth configuration:configuration];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath constraintSize:(CGSize) constraintSize type:(GKAutoLayoutCalculateType) type configuration:(GKCellConfiguration) configuration
{
    NSValue *value = [self gkCachedSizeForIndexPath:indexPath];
    if (value != nil && !CGSizeEqualToSize(CGSizeZero, [value CGSizeValue])){
        return [value CGSizeValue];
    }
    
    //计算大小
    UICollectionReusableView *cell = [self gkCellForIdentifier:identifier];
    !configuration ?: configuration(cell);
    
    UIView *contentView = cell;
    if([cell isKindOfClass:[UICollectionViewCell class]]){
        contentView = [(UICollectionViewCell*)cell contentView];
    }
    CGSize size = [contentView gkSizeThatFits:constraintSize type:type];
    
    [self gkSetCellSize:[NSValue valueWithCGSize:size] forIndexPath:indexPath];
    
    return size;
}


//MARK: - cell大小缓存

///缓存cell大小的数组
- (NSMutableDictionary<NSNumber*, NSMutableDictionary<NSNumber*, NSValue*>* >*)gkCellSizeCaches
{
    NSMutableDictionary *caches = objc_getAssociatedObject(self, _cmd);
    if(caches == nil){
        caches = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, caches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return caches;
}

///判断是否已有缓存
- (NSValue*)gkCachedSizeForIndexPath:(NSIndexPath*) indexPath
{
    NSMutableDictionary *dic = [[self gkCellSizeCaches] objectForKey:@(indexPath.section)];
    if(dic == nil)
        return nil;
    return [dic objectForKey:@(indexPath.item)];
}

///设置缓存
- (void)gkSetCellSize:(NSValue*) size forIndexPath:(NSIndexPath*) indexPath
{
    NSMutableDictionary *caches = [self gkCellSizeCaches];
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

//MARK:- 注册的 cells

///注册的 class nib
- (NSMutableDictionary*)gkRegisterObjects
{
    NSMutableDictionary *objects = objc_getAssociatedObject(self, _cmd);
    if (objects == nil){
        objects = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, objects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objects;
}

///注册的cells header footer 用来计算
- (__kindof UICollectionReusableView*)gkCellForIdentifier:(NSString *)identifier
{
    NSAssert(identifier != nil, @"identifier 不能为 nil");
    
    NSMutableDictionary<NSString*, UICollectionReusableView*> *cells = objc_getAssociatedObject(self, _cmd);
    if (cells == nil){
        cells = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UICollectionReusableView *view = [cells objectForKey:identifier];
    if(view == nil){
        NSObject *obj = [[self gkRegisterObjects] objectForKey:identifier];
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
- (NSIndexPath*)gkHeaderIndexPathForSection:(NSInteger) section
{
    return [NSIndexPath indexPathForItem:-1 inSection:section];
}

///底部
- (NSIndexPath*)gkFooterIndexPathForSection:(NSInteger) section
{
    return [NSIndexPath indexPathForItem:-2 inSection:section];
}

@end
