//
//  GKCollectionViewTopFlowLayout.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKCollectionViewTopFlowLayout.h"

@interface GKCollectionViewTopFlowLayout ()

///存放全部item布局信息的数组
@property(nonatomic, strong) NSMutableDictionary<NSIndexPath*, UICollectionViewLayoutAttributes*> *layoutAttributes;

@end

@implementation GKCollectionViewTopFlowLayout

- (instancetype)init
{
    self = [super init];
    if(self){
        self.layoutAttributes = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];

    [self.layoutAttributes removeAllObjects];
    NSInteger section = [self.collectionView numberOfSections];
    for(NSInteger i = 0;i < section;i ++){
        
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:i];
        if(numberOfItems >= self.maxRowCount * self.itemCountPerRow){
            for(NSInteger j = 0;j < numberOfItems;j ++){
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                [self.layoutAttributes setObject:attributes forKey:indexPath];
            }
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.item;
    
    /*
     0 2 4 ---\  0 1 2
     1 3 5 ---/  3 4 5 计算转换后对应的item  原来'4'的item为4,转换后为3
     */
    NSInteger page = item / (self.itemCountPerRow * self.maxRowCount);
    // 计算目标item的位置 x 横向偏移  y 竖向偏移
    NSUInteger x = item % self.itemCountPerRow + page * self.itemCountPerRow;
    NSUInteger y = item / self.itemCountPerRow - page * self.maxRowCount;
    // 根据偏移量计算item
    NSInteger newItem = x * self.maxRowCount + y;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:newItem inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *newAttributes = [super layoutAttributesForItemAtIndexPath:newIndexPath];
    newAttributes.indexPath = indexPath;
    
    return newAttributes;
}


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(self.layoutAttributes.count > 0){
        NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
        NSMutableArray *attrs = [NSMutableArray arrayWithCapacity:attributes.count];
        
        for (UICollectionViewLayoutAttributes *attr1 in attributes) {
            UICollectionViewLayoutAttributes *attr2 = self.layoutAttributes[attr1.indexPath];
            if(attr2){
                [attrs addObject:attr2];
            }
        }

        return attrs;
    }else{
        return [super layoutAttributesForElementsInRect:rect];
    }
}

@end
