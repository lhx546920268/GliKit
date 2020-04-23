//
//  GKCollectionViewFlowLayout.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCollectionViewFlowLayout.h"
#import "UIScreen+GKUtils.h"

///装饰key
static NSString *const GKCollectionViewBackgroundDecorator = @"GKCollectionViewBackgroundDecorator";

///区域背景装饰视图
@interface GKCollectionViewBackgroundDecoratorView : UICollectionReusableView

@end

///区域背景装饰信息
@interface GKCollectionViewLayoutDecoratorAttributes : UICollectionViewLayoutAttributes

///背景颜色
@property(nonatomic, strong) UIColor *backgroundColor;

@end

@interface GKCollectionViewFlowLayout()

///是否已实现悬浮头部代理
@property(nonatomic, assign) BOOL shouldStickHeaderDelegate;

///区域背景装饰信息
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, GKCollectionViewLayoutDecoratorAttributes*> *sectionBackgroundDecoratorAttributes;

@end

@implementation GKCollectionViewFlowLayout

- (void)prepareLayout
{
    id<GKCollectionViewFlowLayoutDelegate> delegate = self.s_delegate;
    self.shouldStickHeaderDelegate = [delegate respondsToSelector:@selector(collectionViewFlowLayout:shouldStickHeaderAtSection:)];

    [super prepareLayout];
    
    [self createSectionBackgroundDecoratorAttributes];
}

- (id<GKCollectionViewFlowLayoutDelegate>)s_delegate
{
    return (id<GKCollectionViewFlowLayoutDelegate>)self.collectionView.delegate;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(self.itemAlignment == GKCollectionViewItemAlignmentDefault && !self.shouldStickHeaderDelegate && self.sectionBackgroundDecoratorAttributes.count == 0){
        return [super layoutAttributesForElementsInRect:rect];
    }
    
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    UICollectionViewLayoutAttributes *prevousAttr = nil;
    
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    UIEdgeInsets insets = self.sectionInset;
    NSInteger section = NSNotFound;
    
    ///可见的section，如果该section没有cell，则不需要悬浮，所以这里不包含header
    NSMutableArray *visibleSections = nil;
    
    if(self.shouldStickHeaderDelegate){
        visibleSections = [NSMutableArray array];
        for(UICollectionViewLayoutAttributes *attr in attributes){
            if(![attr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]){
                NSNumber *number = [NSNumber numberWithInteger:attr.indexPath.section];
                if(![visibleSections containsObject:number]){
                    [visibleSections addObject:number];
                }
            }
        }
        
        ///由于系统会把header移除，所以要重新加入
        for(NSNumber *number in visibleSections){
            BOOL should = [self.s_delegate collectionViewFlowLayout:self shouldStickHeaderAtSection:number.integerValue];;
            
            if(should){
                UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:number.integerValue]];
                
                if(attr.frame.size.width > 0 && attr.frame.size.height > 0){
                    [attributes addObject:attr];
                }
            }
        }
    }
    
    
    for(UICollectionViewLayoutAttributes *attr in attributes){
        if(attr.representedElementCategory == UICollectionElementCategoryCell && self.itemAlignment != GKCollectionViewItemAlignmentDefault){
            
            if(section != attr.indexPath.section){
                if([self.s_delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]){
                    minimumInteritemSpacing = [self.s_delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:attr.indexPath.section];
                }
                
                if([self.s_delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
                    insets = [self.s_delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:attr.indexPath.section];
                    section = attr.indexPath.section;
                }
                
                section = attr.indexPath.section;
            }
            
            if(prevousAttr){
                if(attr.frame.origin.y == prevousAttr.frame.origin.y){
                    CGRect frame = attr.frame;
                    frame.origin.x = prevousAttr.frame.origin.x + prevousAttr.frame.size.width + minimumInteritemSpacing;
                    attr.frame = frame;
                }else{
                    ///另起一行了
                    CGRect frame = attr.frame;
                    frame.origin.x = insets.left;
                    attr.frame = frame;
                }
            }else{
                CGRect frame = attr.frame;
                frame.origin.x = insets.left;
                attr.frame = frame;
            }
            
            prevousAttr = attr;
        }else if (self.shouldStickHeaderDelegate && [attr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]){
            BOOL should = [self.s_delegate collectionViewFlowLayout:self shouldStickHeaderAtSection:attr.indexPath.section];;
            
            if(should){
                CGPoint contentOffset = self.collectionView.contentOffset;
                CGPoint originInCollectionView = CGPointMake(attr.frame.origin.x - contentOffset.x, attr.frame.origin.y - contentOffset.y);
                originInCollectionView.y -= self.collectionView.contentInset.top;
                
                CGRect frame = attr.frame;
                
                if (originInCollectionView.y < 0){
                    frame.origin.y += (originInCollectionView.y * -1);
                }
                
                NSInteger numberOfSections = 1;
                if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
                    numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
                }
                
                if (numberOfSections > attr.indexPath.section + 1){
                    UICollectionViewLayoutAttributes *nextHeaderAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:attr.indexPath.section + 1]];
                    CGFloat maxY = nextHeaderAttr.frame.origin.y;
                    if(CGRectGetMaxY(frame) >= maxY){
                        frame.origin.y = maxY - frame.size.height;
                    }
                }
                attr.frame = frame;
            }
            
            ///防止后面的cell覆盖header
            attr.zIndex = NSNotFound;
        }
    }
    
    [self fillDecoratorAttributesInRect:rect forAttributes:attributes];
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if(self.shouldStickHeaderDelegate){
        return YES;
    }
    
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

// MARK: - section 背景颜色

///计算每个section的区域，创建对应布局属性 目前只支持垂直的
- (void)createSectionBackgroundDecoratorAttributes
{
    id<GKCollectionViewFlowLayoutDelegate> delegate = self.s_delegate;

    //计算每个区域的大小
    if([delegate respondsToSelector:@selector(collectionViewFlowLayout:backgroundColorAtSection:)]){

        
        //注册对应的装饰视图
        [self registerClass:GKCollectionViewBackgroundDecoratorView.class forDecorationViewOfKind:GKCollectionViewBackgroundDecorator];
        
        if(!self.sectionBackgroundDecoratorAttributes){
            self.sectionBackgroundDecoratorAttributes = [NSMutableDictionary dictionary];
        }
        //移除以前的
        [self.sectionBackgroundDecoratorAttributes removeAllObjects];
        
        //判断是否已实现对应代理
        BOOL headerSizeDelegate = [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)];
        BOOL footerSizeDelegate = [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)];
        BOOL insetsDelegate = [delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)];
        BOOL rectDelegate = [delegate respondsToSelector:@selector(collectionViewFlowLayout:didFetchRect:atSection:)];
        
        NSInteger section = self.collectionView.numberOfSections;
        
        for(NSInteger i = 0;i < section;i ++){
            UIColor *backgroundColor = [delegate collectionViewFlowLayout:self backgroundColorAtSection:i];
            
            //某个区域没有对应背景颜色 忽略
            if(backgroundColor){
                
                UICollectionViewLayoutAttributes *headerItem = nil;
                UICollectionViewLayoutAttributes *footerItem = nil;
                UICollectionViewLayoutAttributes *firstItem = nil;
                UICollectionViewLayoutAttributes *lastItem = nil;
                
                //获取 header
                CGSize size = self.headerReferenceSize;
                if(headerSizeDelegate){
                    size = [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:i];
                }
                
                if(size.height > 0){
                    headerItem = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                }

                //获取中间 第一个和最后一个item
                NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:i];
                if(numberOfItems > 0){
                    firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                    lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems - 1 inSection:i]];
                }
                
                //获取footer
                size = self.footerReferenceSize;
                if(footerSizeDelegate){
                    size = [delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:i];
                }
                
                if(size.height > 0){
                    footerItem = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                }
                
                //获取区域间隔
                UIEdgeInsets insets = self.sectionInset;
                if(insetsDelegate){
                    insets = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:i];
                }
                
                //都没有 说明这个section大小为0
                if(headerItem || firstItem || lastItem || footerItem || insets.top > 0 || insets.bottom > 0){
                    
                    CGRect rect = CGRectZero;
                    rect.size.width = UIScreen.gkWidth;
                    if(headerItem){
                        rect.origin.y = headerItem.frame.origin.y;
                    }else if (firstItem){
                        rect.origin.y = firstItem.frame.origin.y;
                    }else if (footerItem){
                        rect.origin.y = footerItem.frame.origin.y;
                    }
                    
                    if(insets.top > 0 && !headerItem){
                        rect.origin.y -= insets.top;
                    }
                    
                    if(footerItem){
                        rect.size.height = footerItem.frame.size.height + footerItem.frame.origin.y - rect.origin.y;
                    }else if (lastItem){
                        rect.size.height = lastItem.frame.size.height + lastItem.frame.origin.y - rect.origin.y;
                    }else if (headerItem){
                        rect.size.height = headerItem.frame.size.height + headerItem.frame.origin.y - rect.origin.y;
                    }
                    
                    if(insets.bottom > 0 && !footerItem){
                        rect.size.height += insets.bottom;
                    }
                    
                    if(rectDelegate){
                        rect = [delegate collectionViewFlowLayout:self didFetchRect:rect atSection:i];
                    }
                    
                    GKCollectionViewLayoutDecoratorAttributes *attrs = [GKCollectionViewLayoutDecoratorAttributes layoutAttributesForDecorationViewOfKind:GKCollectionViewBackgroundDecorator withIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
                    attrs.backgroundColor = backgroundColor;
                    attrs.frame = rect;
                    attrs.zIndex = -1;
                    
                    
                    [self.sectionBackgroundDecoratorAttributes setObject:attrs forKey:@(i)];
                }
            }
        }
    }
}

///填充背景装饰
- (void)fillDecoratorAttributesInRect:(CGRect) rect forAttributes:(NSMutableArray<UICollectionViewLayoutAttributes*>*) attributes
{
    if(self.sectionBackgroundDecoratorAttributes.count > 0){
        for(NSNumber *number in self.sectionBackgroundDecoratorAttributes){
            GKCollectionViewLayoutDecoratorAttributes *attr = self.sectionBackgroundDecoratorAttributes[number];
            if(CGRectIntersectsRect(attr.frame, rect)){
                [attributes addObject:attr];
            }
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if(self.sectionBackgroundDecoratorAttributes.count == 0)
        return nil;
    GKCollectionViewLayoutDecoratorAttributes *attrs = self.sectionBackgroundDecoratorAttributes[@(indexPath.section)];
    return attrs;
}

@end


@implementation GKCollectionViewBackgroundDecoratorView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if([layoutAttributes isKindOfClass:[GKCollectionViewLayoutDecoratorAttributes class]]){
        GKCollectionViewLayoutDecoratorAttributes *attr = (GKCollectionViewLayoutDecoratorAttributes*)layoutAttributes;
        self.backgroundColor = attr.backgroundColor;
    }
}

@end

@implementation GKCollectionViewLayoutDecoratorAttributes

@end
