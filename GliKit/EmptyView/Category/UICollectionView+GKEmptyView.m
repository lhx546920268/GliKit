//
//  UICollectionView+CAEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UICollectionView+CAEmptyView.h"
#import <objc/runtime.h>
#import "UIScrollView+CAEmptyView.h"
#import "UIView+CAEmptyView.h"

static char CAShouldShowEmptyViewWhenExistSectionHeaderViewKey;
static char CAShouldShowEmptyViewWhenExistSectionFooterViewKey;

@implementation UICollectionView (CAEmptyView)

#pragma mark- super method

- (void)layoutEmtpyView
{
    [super layoutEmtpyView];
    
    GKEmptyView *emptyView = self.ca_emptyView;
    if(emptyView && emptyView.superview && !emptyView.hidden){
        CGRect frame = emptyView.frame;
        CGFloat y = frame.origin.y;
        
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
            section = [self.dataSource numberOfSectionsInCollectionView:self];
        }
        
        ///获取sectionHeader 高度
        if(self.ca_shouldShowEmptyViewWhenExistSectionHeaderView && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
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
        if(self.ca_shouldShowEmptyViewWhenExistSectionFooterView && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
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
            if(!self.ca_shouldShowEmptyViewWhenExistSectionHeaderView && [self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
                for(NSInteger i = 0; i < section;i ++){
                    UIView *view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                    if(view){
                        empty = NO;
                        break;
                    }
                }
            }
            
            if(empty && !self.ca_shouldShowEmptyViewWhenExistSectionFooterView && [self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
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

#pragma mark- property

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
    if(number){
        return [number boolValue];
    }
    
    return NO;
}

#pragma mark- swizzle

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

- (void)ca_empty_reloadSections:(NSIndexSet *)sections
{
    [self ca_empty_reloadSections:sections];
    [self layoutEmtpyView];
}

- (void)ca_empty_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self ca_empty_insertItemsAtIndexPaths:indexPaths];
    [self layoutEmtpyView];
}

- (void)ca_empty_insertSections:(NSIndexSet *)sections
{
    [self ca_empty_insertSections:sections];
    [self layoutEmtpyView];
}

- (void)ca_empty_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self ca_empty_deleteItemsAtIndexPaths:indexPaths];
    [self layoutEmtpyView];
}

- (void)ca_empty_deleteSections:(NSIndexSet *)sections
{
    [self ca_empty_deleteSections:sections];
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
