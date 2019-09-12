//
//  UICollectionView+GKEmptyView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UICollectionView+GKEmptyView.h"
#import <objc/runtime.h>
#import "UIScrollView+GKEmptyView.h"
#import "UIView+GKEmptyView.h"
#import "UIView+GKUtils.h"

static char GKShouldShowEmptyViewWhenExistSectionHeaderViewKey;
static char GKShouldShowEmptyViewWhenExistSectionFooterViewKey;

@implementation UICollectionView (GKEmptyView)

//MARK: Super Method

- (void)layoutEmtpyView
{
    [super layoutEmtpyView];
    
    GKEmptyView *emptyView = self.gkEmptyView;
    if(emptyView && emptyView.superview && !emptyView.hidden){
        CGRect frame = emptyView.frame;
        CGFloat y = frame.origin.y;
        
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
            section = [self.dataSource numberOfSectionsInCollectionView:self];
        }
        
        ///获取sectionHeader 高度
        if(self.gkShouldShowEmptyViewWhenExistSectionHeaderView && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.delegate;
            
            if([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]){
                for(NSInteger i = 0;i < section;i ++){
                    y += [delegate collectionView:self layout:layout referenceSizeForHeaderInSection:i].height;
                }
            }else{
                y += section * layout.headerReferenceSize.height;
            }
        }
        
        ///获取section footer 高度
        if(self.gkShouldShowEmptyViewWhenExistSectionFooterView && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.delegate;
            
            if([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]){
                for(NSInteger i = 0;i < section;i ++){
                    y += [delegate collectionView:self layout:layout referenceSizeForFooterInSection:i].height;
                }
            }else{
                y += section * layout.footerReferenceSize.height;
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
    
    if(empty && self.dataSource){
        //会触发 reloadData
        //NSInteger section = self.numberOfSections;
        
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
            section = [self.dataSource numberOfSectionsInCollectionView:self];
        }
        
        if([self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]){
            for(NSInteger i = 0;i < section;i ++){
                NSInteger items = [self.dataSource collectionView:self numberOfItemsInSection:i];
                if(items > 0){
                    empty = NO;
                    break;
                }
            }
        }
        
        ///item为0，section 大于0时，可能存在sectionHeader
        if(empty && section > 0){
            if(!self.gkShouldShowEmptyViewWhenExistSectionHeaderView && [self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
            
            if(empty && !self.gkShouldShowEmptyViewWhenExistSectionFooterView && [self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
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
    objc_setAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionFooterViewKey, @(gkShouldShowEmptyViewWhenExistSectionFooterView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldShowEmptyViewWhenExistSectionFooterView
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldShowEmptyViewWhenExistSectionFooterViewKey);
    if(number){
        return [number boolValue];
    }
    
    return NO;
}

//MARK: Swizzle

+ (void)load
{
    SEL selectors[] = {
        
        @selector(reloadData),
        @selector(reloadSections:),
        @selector(insertItemsAtIndexPaths:),
        @selector(insertSections:),
        @selector(deleteItemsAtIndexPaths:),
        @selector(deleteSections:),
        @selector(layoutSubviews) //使用约束时 frame会在layoutSubviews得到
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(NSInteger i = 0;i < count;i ++){
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

- (void)gkEmpty_reloadSections:(NSIndexSet *)sections
{
    [self gkEmpty_reloadSections:sections];
    [self layoutEmtpyView];
}

- (void)gkEmpty_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self gkEmpty_insertItemsAtIndexPaths:indexPaths];
    [self layoutEmtpyView];
}

- (void)gkEmpty_insertSections:(NSIndexSet *)sections
{
    [self gkEmpty_insertSections:sections];
    [self layoutEmtpyView];
}

- (void)gkEmpty_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self gkEmpty_deleteItemsAtIndexPaths:indexPaths];
    [self layoutEmtpyView];
}

- (void)gkEmpty_deleteSections:(NSIndexSet *)sections
{
    [self gkEmpty_deleteSections:sections];
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
