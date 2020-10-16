//
//  UICollectionView+GKCellSize.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UICollectionView+GKCellSize.h"
#import <objc/runtime.h>
#import "UIView+GKAutoLayout.h"
#import "NSObject+GKUtils.h"

@implementation UICollectionView (GKCellSize)

+ (void)load {
    SEL selectors[] = {
        
        @selector(registerNib:forCellWithReuseIdentifier:),
        @selector(registerClass:forCellWithReuseIdentifier:),
        @selector(registerNib:forSupplementaryViewOfKind:withReuseIdentifier:),
        @selector(registerClass:forSupplementaryViewOfKind:withReuseIdentifier:),
    };
    
    for(NSInteger i = 0;i < sizeof(selectors) / sizeof(SEL);i ++){
        
        [self gkExchangeImplementations:selectors[i] prefix:@"gkCellSize_"];
    }
}

// MARK: - register cells

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

// MARK: - 计算

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier model:(id<GKItemSizeModel>) model
{
    return [self gkCellSizeForIdentifier:identifier constraintSize:CGSizeZero model:model];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier constraintSize:(CGSize) constraintSize model:(id<GKItemSizeModel>) model
{
    return [self gkCellSizeForIdentifier:identifier constraintSize:constraintSize type:GKAutoLayoutCalcTypeSize model:model];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier width:(CGFloat) width model:(id<GKItemSizeModel>) model
{
    return [self gkCellSizeForIdentifier:identifier constraintSize:CGSizeMake(width, 0) type:GKAutoLayoutCalcTypeHeight model:model];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier height:(CGFloat) height model:(id<GKItemSizeModel>) model
{
    return [self gkCellSizeForIdentifier:identifier constraintSize:CGSizeMake(0, height) type:GKAutoLayoutCalcTypeWidth model:model];
}

- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier constraintSize:(CGSize) constraintSize type:(GKAutoLayoutCalcType) type model:(id<GKItemSizeModel>) model
{
    if(CGSizeEqualToSize(model.itemSize, CGSizeZero)){
        //计算大小
        UICollectionReusableView<GKCollectionConfigurableItem> *cell = [self gkCellForIdentifier:identifier];
        NSAssert([cell conformsToProtocol:@protocol(GKCollectionConfigurableItem)], @"cell for identifier %@ must confirms protocol %@", identifier, NSStringFromProtocol(@protocol(GKCollectionConfigurableItem)));
        cell.model = model;
        
        
        UIView *contentView = cell;
        if([cell isKindOfClass:[UICollectionViewCell class]]){
            contentView = [(UICollectionViewCell*)cell contentView];
        }
        model.itemSize = [contentView gkSizeThatFits:constraintSize type:type];
    }
    
    return model.itemSize;
}

// MARK: - 注册的 cells

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
    
    /**
     不用 dequeueReusableCellWithReuseIdentifier 是因为会创建N个cell，并且会报下面的警告
     [CollectionView] An attempt to prepare a layout while a prepareLayout call was already in progress
     */
    
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

@end
