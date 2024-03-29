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

static char GKShouldIgnoreSectionHeaderKey;
static char GKShouldIgnoreSectionFooterKey;

@implementation UICollectionView (GKEmptyView)

// MARK: - Super Method

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
        if(self.gkShouldIgnoreSectionHeader && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
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
        if(self.gkShouldIgnoreSectionFooter && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
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
    
    if(empty && self.dataSource){
        //会触发 reloadData
        //NSInteger section = self.numberOfSections;
        
        NSInteger section = 1;
        if([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
            section = [self.dataSource numberOfSectionsInCollectionView:self];
        }
        
        for(NSInteger i = 0;i < section;i ++){
            NSInteger items = [self.dataSource collectionView:self numberOfItemsInSection:i];
            if(items > 0){
                empty = NO;
                break;
            }
        }
        
        ///item为0，section 大于0时，可能存在sectionHeader
        if(empty && section > 0 && [self.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]){
            
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>) self.delegate;
            if(!self.gkShouldIgnoreSectionHeader){

                if([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]){
                    for(NSInteger i = 0;i < section;i ++){
                        CGSize size = [delegate collectionView:self layout:layout referenceSizeForHeaderInSection:i];
                        if(size.height > 0){
                            empty = NO;
                            break;
                        }
                    }
                }else{
                    empty = layout.headerReferenceSize.height == 0;
                }
            }
            
            if(empty && !self.gkShouldIgnoreSectionFooter){

                if([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]){
                    for(NSInteger i = 0;i < section;i ++){
                        CGSize size = [delegate collectionView:self layout:layout referenceSizeForFooterInSection:i];
                        if(size.height > 0){
                            empty = NO;
                            break;
                        }
                    }
                }else{
                    empty = layout.footerReferenceSize.height == 0;
                }
            }
        }
    }
    
    return empty;
}

// MARK: - Property

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
    objc_setAssociatedObject(self, &GKShouldIgnoreSectionFooterKey, @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkShouldIgnoreSectionFooter
{
    NSNumber *number = objc_getAssociatedObject(self, &GKShouldIgnoreSectionFooterKey);
    if(number != nil){
        return [number boolValue];
    }
    
    return NO;
}

@end
