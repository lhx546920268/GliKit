//
//  GKCollectionViewFlowFillLayout.m
//  ThreadDemo
//
//  Created by 罗海雄 on 16/6/6.
//  Copyright © 2016年 罗海雄. All rights reserved.
//

#import "GKCollectionViewFlowFillLayout.h"
#import "UIScreen+GKUtils.h"
#import "GKCollectionViewLayoutInvalidationContext.h"

@class GKCollectionFlowRowInfo;

///每个section的布局信息
@interface GKCollectionViewFlowFillLayoutAttributes : NSObject

///头部布局信息
@property(nonatomic,strong) UICollectionViewLayoutAttributes *headerLayoutAttributes;

///悬浮的头部布局信息
@property(nonatomic,readonly) UICollectionViewLayoutAttributes *stickHeaderLayoutAttributes;

///底部布局信息
@property(nonatomic,strong) UICollectionViewLayoutAttributes *footerLayoutAttributes;

///item布局信息
@property(nonatomic,strong) NSMutableArray<UICollectionViewLayoutAttributes*> *itemInfos;

///行信息
@property(nonatomic,strong) NSMutableArray<GKCollectionFlowRowInfo*> *rowInfos;

///是否要悬浮头部
@property(nonatomic,assign) BOOL shouldStickHeader;

///section起点
@property(nonatomic,readonly) CGFloat sectionBeginning;

///section终点
@property(nonatomic,readonly) CGFloat sectionEnd;

///是否存在元素
@property(nonatomic,readonly) BOOL existElement;

///item、header、footer 上下间距
@property (nonatomic,assign) CGFloat minimumLineSpacing;

///item左右间距
@property (nonatomic,assign) CGFloat minimumInteritemSpacing;

///section 偏移量
@property (nonatomic,assign) UIEdgeInsets sectionInset;

///关联的布局
@property (nonatomic,weak) GKCollectionViewFlowFillLayout *layout;

@end

///布局行信息
@interface GKCollectionFlowRowInfo : NSObject

///关联的section 布局信息
@property(nonatomic,weak) GKCollectionViewFlowFillLayoutAttributes *layoutAttributes;

///行的最右边的item的 originX加载width
@property(nonatomic,assign) CGFloat rightmost;

///行y轴起点
@property(nonatomic,assign) CGFloat originY;

///最高item的frame
@property(nonatomic,assign) CGRect highestFrame;

///所拥有的item布局信息
@property(nonatomic,strong) NSMutableArray<UICollectionViewLayoutAttributes*> *itemInfos;

///最外一层的item
@property(nonatomic,strong) NSMutableArray<NSValue*> *outmostItemInfos;

///根据item大小获取下一个item的位置 如果point.x < 0 ，表示没有空余的位置放item了
- (CGPoint)itemOriginFromItemSize:(CGSize) size;

@end

@implementation GKCollectionFlowRowInfo

- (instancetype)init
{
    self = [super init];
    if(self){
        self.outmostItemInfos = [NSMutableArray array];
        self.itemInfos = [NSMutableArray array];
    }

    return self;
}

- (CGPoint)itemOriginFromItemSize:(CGSize) size
{
    CGPoint point;

    ///该行没有其他item
    if(self.itemInfos.count == 0){
        point.y = self.originY;
        point.x = self.layoutAttributes.sectionInset.left;
        self.rightmost = point.x + size.width;

        CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
        [self.outmostItemInfos addObject:[NSValue valueWithCGRect:rect]];
        [self updateHighestFrame:rect];
        
        return point;
    }

    CGFloat width = self.layoutAttributes.layout.collectionView.frame.size.width;
    if(width == 0){
        width = UIScreen.gkWidth;
    }
    
    if(size.width + self.layoutAttributes.sectionInset.right + self.layoutAttributes.minimumInteritemSpacing + self.rightmost > width){
        ///这一行已经没有位置可以放item了
        if(self.outmostItemInfos.count < 2){
            point.x = -1;
        }else{
            NSInteger index = [self traverseOutmostItemInfosWithItemSize:size];
            if(index >= self.outmostItemInfos.count){
                point.x = -1;
            }else{
                CGRect frame = [[self.outmostItemInfos objectAtIndex:index] CGRectValue];
                point.x = frame.origin.x;
               
                point.y = frame.size.height + frame.origin.y + self.layoutAttributes.minimumLineSpacing;

                CGRect rect;
                if(size.width < frame.size.width){
                    ///只挡住上面的item的一部分
                    [self.outmostItemInfos replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:CGRectMake(point.x + size.width + self.layoutAttributes.minimumInteritemSpacing, frame.origin.y, frame.size.width - size.width - self.layoutAttributes.minimumInteritemSpacing, frame.size.height)]];
                    
                    rect = CGRectMake(point.x, point.y, size.width, size.height);
                    [self.outmostItemInfos insertObject:[NSValue valueWithCGRect:rect] atIndex:index];
                }else{
                    ///已完全挡住上一个item
                    rect = CGRectMake(point.x, point.y, size.width, size.height);
                    [self.outmostItemInfos replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:rect]];
                }
                [self updateHighestFrame:rect];

                ///合并相同高度的item
                [self combineTheSameHeightItemForIndex:index];
            }
        }
    }else{
        ///右边还有位置可以放item
        point.x = self.rightmost + self.layoutAttributes.minimumInteritemSpacing;
        point.y = self.originY;
        self.rightmost = point.x + size.width;

        CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
        if(self.outmostItemInfos.count == 0){
            [self.outmostItemInfos addObject:[NSValue valueWithCGRect:rect]];
        }else{
            CGRect lastRect = [[self.outmostItemInfos lastObject] CGRectValue];
            ///相邻的item等高，合并
            if(rect.size.height == lastRect.size.height){
                lastRect.size.width += rect.size.width + self.layoutAttributes.minimumInteritemSpacing;
                [self.outmostItemInfos replaceObjectAtIndex:self.outmostItemInfos.count - 1 withObject:[NSValue valueWithCGRect:lastRect]];
            }else{
                [self.outmostItemInfos addObject:[NSValue valueWithCGRect:rect]];
            }
        }
        [self updateHighestFrame:rect];
    }

    return point;
}

///更新最高的frame
- (void)updateHighestFrame:(CGRect) frame
{
    if(frame.origin.y + frame.size.height > self.highestFrame.origin.y + self.highestFrame.size.height){
        self.highestFrame = frame;
    }
}

/**遍历最外围的item，获取最低的并且适合放size的 item
 *@param size 将要存放的item的大小
 *@return 适合存放item的位置，如果返回NSNotFound，标明没有适合的位置
 */
- (NSInteger)traverseOutmostItemInfosWithItemSize:(CGSize) size
{
    NSValue *value = [self.outmostItemInfos firstObject];
    CGRect frame = [value CGRectValue];

    NSInteger index = 0;
    for(NSInteger i = 1;i < self.outmostItemInfos.count;i ++){
        value = [self.outmostItemInfos objectAtIndex:i];
        CGRect rect = [value CGRectValue];
        ///最低，并且可以放下item
        if(rect.origin.y + rect.size.height <= frame.origin.y + frame.size.height && rect.size.width >= size.width){
            if(rect.origin.y + rect.size.height == frame.origin.y + frame.size.height){
                //拿最左边的
                if(rect.origin.x < frame.origin.x){
                    frame = rect;
                    index = i;
                }
            }else{
                frame = rect;
                index = i;
            }
        }
    }

    if(size.width > frame.size.width){
        index = NSNotFound;
    }

    return index;
}

/**合并相邻的相同高度的item
 *@param index 要合并的位置
 */
- (void)combineTheSameHeightItemForIndex:(NSInteger) index
{
    CGRect frame = [[self.outmostItemInfos objectAtIndex:index] CGRectValue];
    CGFloat bottom = frame.size.height + frame.origin.y;
    
    if(index > 0){
        ///前一个
        CGRect pframe = [[self.outmostItemInfos objectAtIndex:index - 1] CGRectValue];
        CGFloat pBottom = pframe.origin.y + pframe.size.height;
        if(fabs(bottom - pBottom) < 1.0){
            pframe.origin.x = MIN(frame.origin.x, pframe.origin.x);
            pframe.size.width += frame.size.width + self.layoutAttributes.minimumInteritemSpacing;
            
             ///防止出现白边
            if(self.layoutAttributes.minimumLineSpacing == 0){
                if(pBottom > bottom){
                    frame.size.height += pBottom - bottom;
                }else if (bottom > pBottom){
                    pframe.size.height += bottom - pBottom;
                }
            }
            
            [self.outmostItemInfos replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:pframe]];

            frame = pframe;
            [self.outmostItemInfos removeObjectAtIndex:index - 1];
        }
    }

    if(index + 1 < self.outmostItemInfos.count){
        ///后一个
        CGRect pframe = [[self.outmostItemInfos objectAtIndex:index + 1] CGRectValue];
        CGFloat pBottom = pframe.origin.y + pframe.size.height;
        if(fabs(bottom - pBottom) < 1.0){
            pframe.origin.x = MIN(frame.origin.x, pframe.origin.x);
            pframe.size.width += frame.size.width + self.layoutAttributes.minimumInteritemSpacing;
            
            ///防止出现白边
            if(self.layoutAttributes.minimumLineSpacing == 0){
                if(pBottom > bottom){
                    frame.size.height += pBottom - bottom;
                }else if (bottom > pBottom){
                    pframe.size.height += bottom - pBottom;
                }
            }
            
            [self.outmostItemInfos replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:pframe]];

            [self.outmostItemInfos removeObjectAtIndex:index + 1];
        }
    }
}

@end


@implementation GKCollectionViewFlowFillLayoutAttributes

@synthesize stickHeaderLayoutAttributes = _stickHeaderLayoutAttributes;

- (instancetype)init
{
    self = [super init];
    if(self){
        self.rowInfos = [NSMutableArray array];
    }

    return self;
}

///section起点
- (CGFloat)sectionBeginning
{
    if(self.headerLayoutAttributes){
        return self.headerLayoutAttributes.frame.origin.y;
    }

    if(self.rowInfos.count > 0){
        GKCollectionFlowRowInfo *info = [self.rowInfos firstObject];
        return info.originY;
    }else{
        return self.footerLayoutAttributes.frame.origin.y;
    }
}

///section终点
- (CGFloat)sectionEnd
{
    if(self.footerLayoutAttributes){
        return self.footerLayoutAttributes.frame.origin.y + self.footerLayoutAttributes.frame.size.height;
    }

    if(self.rowInfos.count > 0){
        GKCollectionFlowRowInfo *info = [self.rowInfos lastObject];

        return info.highestFrame.origin.y + info.highestFrame.size.height;
    }else{
        return self.headerLayoutAttributes.frame.origin.y + self.headerLayoutAttributes.frame.size.height;
    }
}

///是否存在元素
- (BOOL)existElement
{
    return self.headerLayoutAttributes != nil || self.itemInfos.count > 0 || self.footerLayoutAttributes != nil;
}

///获取悬浮的header attr
- (UICollectionViewLayoutAttributes*)stickHeaderLayoutAttributes
{
    if(self.headerLayoutAttributes){
        if(!_stickHeaderLayoutAttributes){
            _stickHeaderLayoutAttributes = [self.headerLayoutAttributes copy];
        }
        _stickHeaderLayoutAttributes.zIndex = NSNotFound;
        return _stickHeaderLayoutAttributes;
    }
    
    return nil;
}

///是否需要悬浮
- (BOOL)shouldStickHeader
{
    return _shouldStickHeader && self.headerLayoutAttributes;
}

@end

@interface GKCollectionViewFlowFillLayout()

/**
 collectonView 代理
 */
@property(nonatomic,readonly) id<GKCollectionViewFlowFillLayoutDelegate> delegate;

/**
 内容大小
 */
@property(nonatomic,assign) CGSize contentSize;

/**
 布局属性
 */
@property(nonatomic,strong) NSMutableArray<GKCollectionViewFlowFillLayoutAttributes*> *attributes;

/**
 是否已实现悬浮头部代理
 */
@property(nonatomic,assign) BOOL shouldStickHeaderDelegate;

@end

@implementation GKCollectionViewFlowFillLayout

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
    _minimumInteritemSpacing = 5.0;
    _minimumLineSpacing = 5.0;
    _sectionHeaderHeight = 0;
    _sectionFooterHeight = 0;
    _sectionFooterItemSpace = 5.0;
    _sectionHeaderItemSpace = 5.0;
    _sectionInset = UIEdgeInsetsZero;
    self.attributes = [NSMutableArray array];
}

// MARK: - 内容大小

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

/**
 * 计算内容大小
 */
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
    BOOL sectionHeaderHeightDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:headerHeightAtSection:)];
    BOOL sectionFooterHeightDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:footerHeightAtSection:)];
    BOOL sectionInsetDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:insetForSectionAtIndex:)];
    BOOL minimumInteritemSpacingDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:minimumInteritemSpacingForSection:)];
    BOOL minimumLineSpacingDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:minimumLineSpacingForSection:)];
    
    BOOL sectionFooterItemSpaceDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:footerItemSpaceAtSection:)];
    BOOL sectionHeaderItemSpaceDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:headerItemSpaceAtSection:)];
    BOOL shouldStickHeaderDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:shouldStickHeaderAtSection:)];
    self.shouldStickHeaderDelegate = shouldStickHeaderDelegate;

#ifdef DEBUG
    
    BOOL sizeForItemDelegate = [self.delegate respondsToSelector:@selector(collectionViewFlowFillLayout:itemSizeForIndexPath:)];
    NSAssert(sizeForItemDelegate, @"必须实现 collectionViewFlowFillLayout:itemSizeForIndexPath:");
#endif

    [self.collectionView.superview layoutIfNeeded];
    CGFloat width = self.collectionView.bounds.size.width;
    if(width == 0){
        width = UIScreen.gkWidth;
    }
    //计算内容高度
    CGFloat height = 0;

    for(NSInteger section = 0;section < numberOfSections;section ++){
        GKCollectionViewFlowFillLayoutAttributes *layoutAttributes = [[GKCollectionViewFlowFillLayoutAttributes alloc] init];
        layoutAttributes.layout = self;
        if(shouldStickHeaderDelegate){
            layoutAttributes.shouldStickHeader = [self.delegate collectionViewFlowFillLayout:self shouldStickHeaderAtSection:section];
        }

        [self.attributes addObject:layoutAttributes];

        //获取区域偏移量
        if(sectionInsetDelegate){
            sectionInset = [self.delegate collectionViewFlowFillLayout:self insetForSectionAtIndex:section];
        }

        height += sectionInset.top;

        //获取头部高度
        if(sectionHeaderHeightDelegate){
            //实现了代理
            sectionHeaderHeight = [self.delegate collectionViewFlowFillLayout:self headerHeightAtSection:section];
        }

        ///item与header的间距
        if(sectionHeaderItemSpaceDelegate){
            sectionHeaderItemSpace = [self.delegate collectionViewFlowFillLayout:self headerItemSpaceAtSection:section];
        }

        //左右间距
        if(minimumInteritemSpacingDelegate){
            minimumInteritemSpacing = [self.delegate collectionViewFlowFillLayout:self minimumInteritemSpacingForSection:section];
        }

        //上下间距
        if(minimumLineSpacingDelegate){
            minimumLineSpacing = [self.delegate collectionViewFlowFillLayout:self minimumLineSpacingForSection:section];
        }

        ///item数量
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];

        ///只有当section头部大于0时才显示
        if(sectionHeaderHeight > 0){
            //header布局
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(0, height, width, sectionHeaderHeight);
            layoutAttributes.headerLayoutAttributes = attributes;
            height += sectionHeaderHeight;

            if(numberOfItems > 0)
                height += sectionHeaderItemSpace;
        }

        ///设置布局属性
        layoutAttributes.itemInfos = [NSMutableArray arrayWithCapacity:numberOfItems];
        layoutAttributes.sectionInset = sectionInset;
        layoutAttributes.minimumLineSpacing = minimumLineSpacing;
        layoutAttributes.minimumInteritemSpacing = minimumInteritemSpacing;

        ///创建行信息
        GKCollectionFlowRowInfo *rowInfo = [[GKCollectionFlowRowInfo alloc] init];
        rowInfo.layoutAttributes = layoutAttributes;
        rowInfo.originY = height;;
        [layoutAttributes.rowInfos addObject:rowInfo];

        //计算item 大小位置
        for(NSInteger item = 0;item < numberOfItems;item ++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGSize itemSize = [self.delegate collectionViewFlowFillLayout:self itemSizeForIndexPath:indexPath];
            
            ///取1位小数 防止因为无穷小数导致 出现白边
//            if(minimumInteritemSpacing == 0)
//            {
                itemSize.width = ((int)(itemSize.width * 10.0)) / 10.0;
          //  }
            
            if(minimumLineSpacing == 0){
                itemSize.height = ((int)(itemSize.height * 10.0)) / 10.0;
            }
            
            ///位置已超出上一行
            CGPoint point = [rowInfo itemOriginFromItemSize:itemSize];
            if(point.x < 0){
                height += rowInfo.highestFrame.origin.y - rowInfo.originY + rowInfo.highestFrame.size.height + minimumLineSpacing;
                rowInfo = [[GKCollectionFlowRowInfo alloc] init];
                rowInfo.layoutAttributes = layoutAttributes;
                rowInfo.originY = height;;

                point = [rowInfo itemOriginFromItemSize:itemSize];
                [layoutAttributes.rowInfos addObject:rowInfo];
            }
            
//            if(minimumInteritemSpacing == 0)
//            {
                ///右边填满 防止因为无穷小数导致 出现白边
                if(sectionInset.right == 0 && width - point.x - itemSize.width < 1.0)
                {
                    itemSize.width = width - point.x;
                }
           // }

            //item布局
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(point.x, point.y, itemSize.width, itemSize.height);
        
            
            [layoutAttributes.itemInfos addObject:attributes];
            [rowInfo.itemInfos addObject:attributes];
        }

        //添加item的最高列
        height += rowInfo.highestFrame.size.height + rowInfo.highestFrame.origin.y - rowInfo.originY;

        //获取底部高度
        if(sectionFooterHeightDelegate){
            //实现了代理
            sectionFooterHeight = [self.delegate collectionViewFlowFillLayout:self footerHeightAtSection:section];
        }

        ///item与底部的间距
        if(sectionFooterItemSpaceDelegate){
            sectionFooterItemSpace = [self.delegate collectionViewFlowFillLayout:self footerItemSpaceAtSection:section];
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

        height += sectionFooterHeight;
        height += sectionInset.bottom;
    }

    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, height);
}

- (void)prepareLayout
{
    [super prepareLayout];

    [self caculateContentSize];
}

// MARK: - property

- (id<GKCollectionViewFlowFillLayoutDelegate>)delegate
{
    return (id<GKCollectionViewFlowFillLayoutDelegate>)self.collectionView.delegate;
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
    if(_sectionFooterHeight != sectionHeaderHeight){
        _sectionFooterHeight = sectionHeaderHeight;
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
        GKCollectionViewFlowFillLayoutAttributes *attribute = self.attributes[i];
        ///该区域没有元素
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
        
        ///section的头部超过rect的底部，该section以后的元素都不存在于该区域
        if(attribute.sectionBeginning > bottom){
            break;
        }
        
        ///section的底部小于rect的头部，改section的元素不存在该区域，继续查询下一个section
        if(attribute.sectionEnd < top){
            continue;
        }

        for(UICollectionViewLayoutAttributes *layoutAttributes in attribute.itemInfos){
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
                ///已超过范围
                break;
            }
        }
    }

    return attributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKCollectionViewFlowFillLayoutAttributes *attributes = [self.attributes objectAtIndex:indexPath.section];

    return [attributes.itemInfos objectAtIndex:indexPath.item];
}


- (UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    GKCollectionViewFlowFillLayoutAttributes *attributes = [self.attributes objectAtIndex:indexPath.section];
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

+ (Class)invalidationContextClass
{
    return GKCollectionViewLayoutInvalidationContext.class;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    ///当要悬浮头部时要更新 header的frame
    if(self.shouldStickHeaderDelegate){
        return YES;
    }
    return NO;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    GKCollectionViewLayoutInvalidationContext *context = [GKCollectionViewLayoutInvalidationContext new];
    
    for(NSInteger i = 0;i < self.attributes.count;i ++){
        GKCollectionViewFlowFillLayoutAttributes *attribute = self.attributes[i];
        ///该区域没有元素
        if(!attribute.existElement){
            continue;
        }
        
        if(attribute.headerLayoutAttributes && attribute.shouldStickHeader){
            //悬浮头部
            UICollectionViewLayoutAttributes *attr = [self stickHeaderLayoutAttributesFromAttribute:attribute section:i];
            
            CGRect frame = attr.frame;
            //判断还在不在可见区域内
            if(frame.origin.y + frame.size.height > self.collectionView.contentOffset.y){
                context.invalidSupplementaryIndexPaths = @{
                                                           UICollectionElementKindSectionHeader : @[attr.indexPath]
                                                           };
                break;
            }
        }
    }
    
    return context;
}

///获取悬浮头部属性
- (UICollectionViewLayoutAttributes*)stickHeaderLayoutAttributesFromAttribute:(GKCollectionViewFlowFillLayoutAttributes*) attribute section:(NSUInteger) section
{
    UICollectionViewLayoutAttributes *attr = attribute.stickHeaderLayoutAttributes;
    CGRect frame = attr.frame;
    CGFloat offsetY = self.collectionView.contentOffset.y;
    frame.origin.y = MAX(offsetY, attribute.headerLayoutAttributes.frame.origin.y);
    GKCollectionViewFlowFillLayoutAttributes *nextAttribute = [self nextStickAttributesForSection:section];
    
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

///获取某个区域对应的头部属性
- (GKCollectionViewFlowFillLayoutAttributes*)attributesForBounds:(CGRect) bounds
{
    GKCollectionViewFlowFillLayoutAttributes *attributes = nil;
    
    for(GKCollectionViewFlowFillLayoutAttributes *attr in self.attributes){
        if(attr.sectionBeginning >= bounds.origin.y || attr.sectionEnd <= bounds.origin.y + bounds.size.height){
            attributes = attr;
            break;
        }
    }
    
    return attributes;
}

///获取下一个需要悬浮的头部属性
- (GKCollectionViewFlowFillLayoutAttributes*)nextStickAttributesForSection:(NSUInteger) section
{
    GKCollectionViewFlowFillLayoutAttributes *attributes = nil;
    for(NSUInteger i = section + 1;i < self.attributes.count;i ++){
        GKCollectionViewFlowFillLayoutAttributes *attr = self.attributes[i];
        if(attr.shouldStickHeader){
            attributes = attr;
            break;
        }
    }
    
    return attributes;
}

@end
