//
//  GKCollectionStaggerFlowHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2021/8/24.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKCollectionViewStaggerLayoutAttributes;

///布局帮助类
@interface GKCollectionStaggerFlowHelper : NSObject

///关联的section 布局信息
@property(nonatomic, weak, nullable) GKCollectionViewStaggerLayoutAttributes *layoutAttributes;

///容器大小
@property(nonatomic, assign) CGSize containerSize;

///行的最右边的item的 originX加载width
@property(nonatomic, assign) CGFloat rightmost;

///行y轴起点
@property(nonatomic, assign) CGFloat originY;

///最高item的frame
@property(nonatomic, assign) CGRect highestFrame;

///所拥有的item布局信息
@property(nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*> *itemAttrs;

///最外一层的item frame
@property(nonatomic, strong) NSMutableArray<NSValue*> *outmostItemFrames;

///重置
- (void)reset;

///根据item大小获取下一个item的位置 如果point.x < 0 ，表示没有空余的位置放item了
- (CGPoint)itemOriginFromItemSize:(CGSize) size;

@end

NS_ASSUME_NONNULL_END
