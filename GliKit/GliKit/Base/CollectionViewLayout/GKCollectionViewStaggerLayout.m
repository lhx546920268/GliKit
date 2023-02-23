//
//  GKCollectionViewStaggerLayout.m
//  ThreadDemo
//
//  Created by 罗海雄 on 16/6/6.
//  Copyright © 2016年 罗海雄. All rights reserved.
//

#import "GKCollectionViewStaggerLayout.h"
#import "UIScreen+GKUtils.h"
#import "GKCollectionViewLayoutInvalidationContext.h"
#import "GKCollectionViewStaggerLayoutAttributes.h"
#import "GKCollectionStaggerFlowHelper.h"

@interface GKCollectionViewStaggerLayout()

///内容大小
@property(nonatomic, assign) CGSize contentSize;

///布局属性
@property(nonatomic, strong) NSMutableArray<GKCollectionViewStaggerLayoutAttributes*> *attributes;

///是否已实现悬浮头部代理
@property(nonatomic, assign) BOOL hasStickHeaderDelegate;

///区域背景装饰信息
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, GKCollectionViewStaggerLayoutDecoratorAttributes*> *sectionBackgroundDecoratorAttributes;

@end

@implementation GKCollectionViewStaggerLayout

- (instancetype)init
{
    self = [super init];
    if(self){
        [self initParams];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initParams];
    }

    return self;
}

///初始化
- (void)initParams
{
    self.attributes = [NSMutableArray array];
}

// MARK: - 内容大小

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

///计算内容大小
- (void)caculateContentSize
{
    [self.attributes removeAllObjects];

    NSInteger numberOfSections = [self.collectionView numberOfSections];

    //原始属性，如果不实现代理，则使用这些值
    CGFloat sectionHeaderHeight = self.sectionHeaderHeight;
    CGFloat sectionFooterHeight = self.sectionFooterHeight;
    UIEdgeInsets sectionInset = self.sectionInset;
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    CGFloat sectionFooterItemSpace = self.sectionFooterItemSpace;
    CGFloat sectionHeaderItemSpace = self.sectionHeaderItemSpace;

    //判断是否已实现了代理
    BOOL sectionHeaderHeightDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:headerHeightAtSection:)];
    BOOL sectionFooterHeightDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:footerHeightAtSection:)];
    BOOL sectionInsetDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:insetForSectionAtIndex:)];
    BOOL minimumInteritemSpacingDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:minimumInteritemSpacingForSection:)];
    BOOL minimumLineSpacingDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:minimumLineSpacingForSection:)];
    
    BOOL sectionFooterItemSpaceDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:footerItemSpaceAtSection:)];
    BOOL sectionHeaderItemSpaceDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:headerItemSpaceAtSection:)];
    BOOL hasStickHeaderDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:shouldStickHeaderAtSection:)];
    self.hasStickHeaderDelegate = hasStickHeaderDelegate;
    
    BOOL hasDecorationDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:hasDecorationViewAtSection:)];
    BOOL rectDelegate = [self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:didFetchRect:atSection:)];
    if (hasDecorationDelegate) {
        //注册对应的装饰视图
        [self registerClass:GKCollectionViewStaggerLayoutDecoratorView.class forDecorationViewOfKind:GKCollectionViewStaggerLayoutDecorator];
        
        if(!self.sectionBackgroundDecoratorAttributes){
            self.sectionBackgroundDecoratorAttributes = [NSMutableDictionary dictionary];
        }
        //移除以前的
        [self.sectionBackgroundDecoratorAttributes removeAllObjects];
    }

    NSAssert([self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:itemSizeForIndexPath:)], @"必须实现 collectionViewStaggerLayout:itemSizeForIndexPath:");

    CGFloat width = self.collectionView.frame.size.width;
    if(width == 0){
        width = UIScreen.gkWidth;
    }
    
    //计算内容高度
    CGFloat height = 0;
    
    //创建行信息
    GKCollectionStaggerFlowHelper *helper = [GKCollectionStaggerFlowHelper new];
    helper.containerSize = self.collectionView.frame.size;

    for(NSInteger section = 0; section < numberOfSections; section ++){
        GKCollectionViewStaggerLayoutAttributes *layoutAttributes = [[GKCollectionViewStaggerLayoutAttributes alloc] init];
        if(hasStickHeaderDelegate){
            layoutAttributes.shouldStickHeader = [self.delegate collectionViewStaggerLayout:self shouldStickHeaderAtSection:section];
        }

        [self.attributes addObject:layoutAttributes];

        //获取区域偏移量
        if(sectionInsetDelegate){
            sectionInset = [self.delegate collectionViewStaggerLayout:self insetForSectionAtIndex:section];
        }

        height += sectionInset.top;

        //获取头部高度
        if(sectionHeaderHeightDelegate){
            //实现了代理
            sectionHeaderHeight = [self.delegate collectionViewStaggerLayout:self headerHeightAtSection:section];
        }

        //item与header的间距
        if(sectionHeaderItemSpaceDelegate){
            sectionHeaderItemSpace = [self.delegate collectionViewStaggerLayout:self headerItemSpaceAtSection:section];
        }

        //左右间距
        if(minimumInteritemSpacingDelegate){
            minimumInteritemSpacing = [self.delegate collectionViewStaggerLayout:self minimumInteritemSpacingForSection:section];
        }

        //上下间距
        if(minimumLineSpacingDelegate){
            minimumLineSpacing = [self.delegate collectionViewStaggerLayout:self minimumLineSpacingForSection:section];
        }

        //item数量
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];

        //只有当section头部大于0时才显示
        if(sectionHeaderHeight > 0){
            //header布局
            GKCollectionViewHeaderLayoutAttributes *attributes = [GKCollectionViewHeaderLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(0, height, width, sectionHeaderHeight);
            layoutAttributes.headerLayoutAttributes = attributes;
            height += sectionHeaderHeight;

            if(numberOfItems > 0)
                height += sectionHeaderItemSpace;
        }

        //设置布局属性
        layoutAttributes.itemAttrs = [NSMutableArray arrayWithCapacity:numberOfItems];
        layoutAttributes.sectionInset = sectionInset;
        layoutAttributes.minimumLineSpacing = minimumLineSpacing;
        layoutAttributes.minimumInteritemSpacing = minimumInteritemSpacing;

        [helper reset];
        helper.layoutAttributes = layoutAttributes;
        helper.originY = height;;
        helper.highestFrame = CGRectMake(0, height, 0, 0);

        //计算item 大小位置
        for(NSInteger item = 0; item < numberOfItems; item ++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGSize itemSize = [self.delegate collectionViewStaggerLayout:self itemSizeForIndexPath:indexPath];
            
            //取1位小数 防止因为无穷小数导致 出现白边
            itemSize.width = ((int)(itemSize.width * 10.0)) / 10.0;
            
            if(minimumLineSpacing == 0){
                itemSize.height = ((int)(itemSize.height * 10.0)) / 10.0;
            }
            
            //位置已超出上一行
            CGPoint point = [helper itemOriginFromItemSize:itemSize];
            if(point.x < 0){
                height += helper.highestFrame.origin.y - helper.originY + helper.highestFrame.size.height + minimumLineSpacing;
                
                [helper reset];
                helper.layoutAttributes = layoutAttributes;
                helper.originY = height;;

                point = [helper itemOriginFromItemSize:itemSize];
            }
            
            //右边填满 防止因为无穷小数导致 出现白边
            if(sectionInset.right == 0 && width - point.x - itemSize.width < 1.0){
                itemSize.width = width - point.x;
            }

            //item布局
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(point.x, point.y, itemSize.width, itemSize.height);
        
            [layoutAttributes.itemAttrs addObject:attributes];
            [helper.itemAttrs addObject:attributes];
        }

        //添加item的最高列
        height += helper.highestFrame.size.height + helper.highestFrame.origin.y - helper.originY;

        //获取底部高度
        if(sectionFooterHeightDelegate){
            //实现了代理
            sectionFooterHeight = [self.delegate collectionViewStaggerLayout:self footerHeightAtSection:section];
        }

        //item与底部的间距
        if(sectionFooterItemSpaceDelegate){
            sectionFooterItemSpace = [self.delegate collectionViewStaggerLayout:self footerItemSpaceAtSection:section];
        }

        //只有当section底部大于0时才显示
        if(sectionFooterHeight > 0){
            //section的item不为空，底部存在，要添加底部与item的间距
            if(numberOfItems > 0){
                height += sectionFooterItemSpace;
            }

            //footer布局
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(0, height, width, sectionFooterHeight);
            layoutAttributes.footerLayoutAttributes = attributes;
        }

        layoutAttributes.highestFrame = helper.highestFrame;
        height += sectionFooterHeight;
        height += sectionInset.bottom;
        
        //装饰
        if (hasDecorationDelegate && [self.delegate collectionViewStaggerLayout:self hasDecorationViewAtSection:section]) {
            CGRect rect = CGRectMake(sectionInset.left, layoutAttributes.sectionBeginning, width - sectionInset.left - sectionInset.right, layoutAttributes.sectionEnd - layoutAttributes.sectionBeginning);
            if(rectDelegate){
                rect = [self.delegate collectionViewStaggerLayout:self didFetchRect:rect atSection:section];
            }
            
            GKCollectionViewStaggerLayoutDecoratorAttributes *attrs = [GKCollectionViewStaggerLayoutDecoratorAttributes layoutAttributesForDecorationViewOfKind:GKCollectionViewStaggerLayoutDecorator withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attrs.layout = self;
            attrs.frame = rect;
            attrs.zIndex = -1;
            
            
            [self.sectionBackgroundDecoratorAttributes setObject:attrs forKey:@(section)];
        }
    }

    self.contentSize = CGSizeMake(self.collectionView.frame.size.width, height);
}

- (void)prepareLayout
{
    [super prepareLayout];

    if (!self.hasStickHeaderDelegate || CGSizeEqualToSize(self.contentSize, CGSizeZero) || self.markInvalid) {
        self.markInvalid = NO;
        [self caculateContentSize];
    }
}

// MARK: - property

- (id<GKCollectionViewStaggerLayoutDelegate>)delegate
{
    return (id<GKCollectionViewStaggerLayoutDelegate>)self.collectionView.delegate;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    if(_minimumInteritemSpacing != minimumInteritemSpacing){
        _minimumInteritemSpacing = minimumInteritemSpacing;
        if(![self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]){
            [self invalidateLayout];
        }
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    if(_minimumLineSpacing != minimumLineSpacing){
        _minimumLineSpacing = minimumLineSpacing;
        if(![self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]){
            [self invalidateLayout];
        }
    }
}

- (void)setSectionHeaderHeight:(CGFloat)sectionHeaderHeight
{
    if(_sectionHeaderHeight != sectionHeaderHeight){
        _sectionHeaderHeight = sectionHeaderHeight;
        if(![self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]){
            [self invalidateLayout];
        }
    }
}

- (void)setSectionFooterHeight:(CGFloat)sectionFooterHeight
{
    if(_sectionFooterHeight != sectionFooterHeight){
        _sectionFooterHeight = sectionFooterHeight;
        if(![self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]){
            [self invalidateLayout];
        }
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)){
        _sectionInset = sectionInset;
        if(![self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
            [self invalidateLayout];
        }
    }
}

// MARK: - 布局属性 layout

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    CGFloat top = rect.origin.y;
    CGFloat bottom = top + rect.size.height;

    //有时宽度为空 CGRectIntersectsRect 计算会失败
    if(rect.size.width == 0){
        rect.size.width = self.collectionView.frame.size.width;
    }
    
    if(rect.size.width == 0){
        rect.size.width = UIScreen.gkWidth;
    }
    

    for(NSInteger i = 0;i < self.attributes.count;i ++){
        GKCollectionViewStaggerLayoutAttributes *attribute = self.attributes[i];
        //该区域没有元素
        if(!attribute.existElement){
            continue;
        }

        if(attribute.headerLayoutAttributes){
            
            if(attribute.shouldStickHeader){
                
                //悬浮头部
                UICollectionViewLayoutAttributes *attr = [self stickHeaderLayoutAttributesFromAttribute:attribute section:i];
                
                CGRect frame = attr.frame;
                //判断还在不在可见区域内
                if(frame.origin.y + frame.size.height > self.collectionView.contentOffset.y){
                    [attributes addObject:attr];
                }
            }else{
                if(CGRectIntersectsRect(rect, attribute.headerLayoutAttributes.frame)){
                    [attributes addObject:attribute.headerLayoutAttributes];
                }
            }
        }
        
        //section的头部超过rect的底部，该section以后的元素都不存在于该区域
        if(attribute.sectionBeginning > bottom){
            break;
        }
        
        //section的底部小于rect的头部，改section的元素不存在该区域，继续查询下一个section
        if(attribute.sectionEnd < top){
            continue;
        }

        for(UICollectionViewLayoutAttributes *layoutAttributes in attribute.itemAttrs){
            if(layoutAttributes.frame.origin.y > bottom)
                break;
            if(CGRectIntersectsRect(rect, layoutAttributes.frame)){
                [attributes addObject:layoutAttributes];
            }
        }

        if(attribute.footerLayoutAttributes){
            if(CGRectIntersectsRect(rect, attribute.footerLayoutAttributes.frame)){
                [attributes addObject:attribute.footerLayoutAttributes];
            }else{
                //已超过范围
                break;
            }
        }
    }
    
    [self fillDecoratorAttributesInRect:rect forAttributes:attributes];

    return attributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKCollectionViewStaggerLayoutAttributes *attributes = self.attributes[indexPath.section];

    return attributes.itemAttrs[indexPath.item];
}


- (UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GKCollectionViewStaggerLayoutAttributes *attributes = self.attributes[indexPath.section];
    if([elementKind isEqualToString:UICollectionElementKindSectionFooter]){
        return attributes.footerLayoutAttributes;
    }else if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]){
        if(attributes.shouldStickHeader){
            return [self stickHeaderLayoutAttributesFromAttribute:attributes section:indexPath.section];
        }else{
            return attributes.headerLayoutAttributes;
        }
    }
    
    return nil;
}

// MARK: - 悬浮吸顶

+ (Class)invalidationContextClass
{
    return GKCollectionViewLayoutInvalidationContext.class;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //当要悬浮头部时要更新 header的frame
    if(self.hasStickHeaderDelegate){
        return YES;
    }
    return NO;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    UICollectionViewLayoutInvalidationContext *superContext = [super invalidationContextForBoundsChange:newBounds];
    GKCollectionViewLayoutInvalidationContext *context;
    if(![superContext isKindOfClass:UICollectionViewLayoutInvalidationContext.class]) {
        context = [GKCollectionViewLayoutInvalidationContext new];
    } else {
        context = (GKCollectionViewLayoutInvalidationContext*)superContext;
    }
    context.invalidSupplementaryIndexPaths = nil;
    
    for(NSInteger i = 0;i < self.attributes.count;i ++){
        GKCollectionViewStaggerLayoutAttributes *attribute = self.attributes[i];
        //该区域没有元素
        if(!attribute.existElement){
            continue;
        }
        
        if(attribute.headerLayoutAttributes && attribute.shouldStickHeader){
            //悬浮头部
            UICollectionViewLayoutAttributes *attr = [self stickHeaderLayoutAttributesFromAttribute:attribute section:i];
            
            CGRect frame = attr.frame;
            //判断还在不在可见区域内
            if(frame.origin.y + frame.size.height > self.collectionView.contentOffset.y){
                context.invalidSupplementaryIndexPaths = @{UICollectionElementKindSectionHeader : @[attr.indexPath]};
                break;
            }
        }
    }
    
    return context;
}

///获取悬浮头部属性
- (GKCollectionViewHeaderLayoutAttributes*)stickHeaderLayoutAttributesFromAttribute:(GKCollectionViewStaggerLayoutAttributes*) attribute section:(NSUInteger) section
{
    GKCollectionViewHeaderLayoutAttributes *attr = attribute.stickHeaderLayoutAttributes;
    CGRect frame = attr.frame;
    CGFloat offsetY = self.collectionView.contentOffset.y;
    frame.origin.y = MAX(offsetY, attribute.headerLayoutAttributes.frame.origin.y);
    GKCollectionViewStaggerLayoutAttributes *nextAttribute = [self nextStickAttributesForSection:section];
    BOOL stick = offsetY >= attribute.headerLayoutAttributes.frame.origin.y;
    if (stick != attr.sticking) {
        attr.sticking = stick;
        if ([self.delegate respondsToSelector:@selector(collectionViewStaggerLayout:headerStickDidChange:atIndexPath:)]) {
            [self.delegate collectionViewStaggerLayout:self headerStickDidChange:stick atIndexPath:attribute.headerLayoutAttributes.indexPath];
        }
    }
    
    //下一个悬浮头部要把当前的顶上去
    if(nextAttribute){
        CGFloat value = nextAttribute.headerLayoutAttributes.frame.origin.y - offsetY - attribute.headerLayoutAttributes.frame.size.height;
        if(value < 0){
            frame.origin.y += value;
        }
    }
    
    attr.frame = frame;
    
    return attr;
}

///获取下一个需要悬浮的头部属性
- (GKCollectionViewStaggerLayoutAttributes*)nextStickAttributesForSection:(NSUInteger) section
{
    GKCollectionViewStaggerLayoutAttributes *attributes = nil;
    for(GKCollectionViewStaggerLayoutAttributes *attr in self.attributes){
        if(attr.shouldStickHeader){
            attributes = attr;
            break;
        }
    }
    
    return attributes;
}

// MARK: - 装饰背景

///填充背景装饰
- (void)fillDecoratorAttributesInRect:(CGRect) rect forAttributes:(NSMutableArray<UICollectionViewLayoutAttributes*>*) attributes
{
    if(self.sectionBackgroundDecoratorAttributes.count > 0){
        for(NSNumber *number in self.sectionBackgroundDecoratorAttributes){
            GKCollectionViewStaggerLayoutDecoratorAttributes *attr = self.sectionBackgroundDecoratorAttributes[number];
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
    GKCollectionViewStaggerLayoutDecoratorAttributes *attrs = self.sectionBackgroundDecoratorAttributes[@(indexPath.section)];
    return attrs;
}

@end
