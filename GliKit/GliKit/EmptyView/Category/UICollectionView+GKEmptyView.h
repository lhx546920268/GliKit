//
//  UICollectionView+GKEmptyView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///用于collectionView 的空视图
@interface UICollectionView (GKEmptyView)

///存在 sectionHeader 时，是否显示空视图 default is 'NO'
@property(nonatomic,assign) BOOL gkShouldShowEmptyViewWhenExistSectionHeaderView;

///存在 sectionFooter 时，是否显示空视图 default is 'NO'
@property(nonatomic,assign) BOOL gkShouldShowEmptyViewWhenExistSectionFooterView;

@end
