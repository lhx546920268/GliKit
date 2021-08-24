//
//  GKCollectionViewStaggerLayoutAttributes.h
//  GliKit
//
//  Created by 罗海雄 on 2021/8/24.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKCollectionViewStaggerLayout;

///装饰key
static NSString *const GKCollectionViewStaggerLayoutDecorator = @"GKCollectionViewStaggerLayoutDecorator";

///区域背景装饰视图
@interface GKCollectionViewStaggerLayoutDecoratorView : UICollectionReusableView

@end

///区域背景装饰信息
@interface GKCollectionViewStaggerLayoutDecoratorAttributes : UICollectionViewLayoutAttributes

///代理
@property(nonatomic, weak) GKCollectionViewStaggerLayout *layout;

@end

///头部布局信息
@interface GKCollectionViewHeaderLayoutAttributes : UICollectionViewLayoutAttributes

///是否悬浮
@property(nonatomic, assign) BOOL sticking;

@end

///每个section的布局信息
@interface GKCollectionViewStaggerLayoutAttributes : NSObject

///头部布局信息
@property(nonatomic, strong) GKCollectionViewHeaderLayoutAttributes *headerLayoutAttributes;

///悬浮的头部布局信息
@property(nonatomic, readonly) GKCollectionViewHeaderLayoutAttributes *stickHeaderLayoutAttributes;

///底部布局信息
@property(nonatomic, strong) UICollectionViewLayoutAttributes *footerLayoutAttributes;

///item布局信息
@property(nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*> *itemAttrs;

///是否要悬浮头部
@property(nonatomic, assign) BOOL shouldStickHeader;

///section起点
@property(nonatomic, readonly) CGFloat sectionBeginning;

///section终点
@property(nonatomic, readonly) CGFloat sectionEnd;

///最高item的frame
@property(nonatomic, assign) CGRect highestFrame;

///是否存在元素
@property(nonatomic, readonly) BOOL existElement;

///item、header、footer 上下间距
@property (nonatomic, assign) CGFloat minimumLineSpacing;

///item左右间距
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

///section 偏移量
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@end

