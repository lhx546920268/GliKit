//
//  UIScrollView+GKEmptyView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///用于UIScrollView的空视图扩展
@interface UIScrollView (GKEmptyView)

/**
 是否显示空视图 default `NO`， 当为YES时，如果是UITableView 或者 UICollectionView，还需要没有数据时才显示
 @warning 如果使用约束，必须在设置父视图后 才设置此值
 */
@property(nonatomic, assign) BOOL gkShouldShowEmptyView;

///空视图偏移量 default `zero`
@property(nonatomic, assign) UIEdgeInsets gkEmptyViewInsets;

///当前是空数据 UIScrollView 一定是空的，其他的不一定
- (BOOL)gkIsEmptyData;

@end

