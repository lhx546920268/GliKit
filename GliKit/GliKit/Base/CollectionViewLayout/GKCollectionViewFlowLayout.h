//
//  GKCollectionViewFlowLayout.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///UICollectionViewFlowLayout item对其方式
typedef NS_ENUM(NSInteger, GKCollectionViewItemAlignment)
{
    ///默认的
    GKCollectionViewItemAlignmentDefault = 0,
    
    ///左对其
    GKCollectionViewItemAlignmentLeft,
};

@class GKCollectionViewFlowLayout;

///自定义流布局代理
@protocol GKCollectionViewFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional

///是否需要悬浮 default `NO`
- (BOOL)collectionViewFlowLayout:(GKCollectionViewFlowLayout*) layout shouldStickHeaderAtSection:(NSInteger) section;

///每个区域的背景颜色
- (nullable UIColor*)collectionViewFlowLayout:(GKCollectionViewFlowLayout*) layout backgroundColorAtSection:(NSInteger) section;

///每个区域的背景 rect 用来微调 返回新的rect
- (CGRect)collectionViewFlowLayout:(GKCollectionViewFlowLayout*) layout didFetchRect:(CGRect) rect atSection:(NSInteger) section;

@end

///自定义流布局
@interface GKCollectionViewFlowLayout : UICollectionViewFlowLayout

///对其方式 default `GKCollectionViewItemAlignmentDefault`
@property(nonatomic, assign) GKCollectionViewItemAlignment itemAlignment;

@end

NS_ASSUME_NONNULL_END
