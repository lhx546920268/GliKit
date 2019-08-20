//
//  UIScrollView+CAEmptyView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///用于UIScrollView的空视图扩展
@interface UIScrollView (CAEmptyView)

/**
 是否显示空视图 default is 'NO'， 当为YES时，如果是UITableView 或者 UICollectionView，还需要没有数据时才显示
 @warning 如果使用约束，必须在设置父视图后 才设置此值
 */
@property(nonatomic,assign) BOOL ca_shouldShowEmptyView;

///空视图偏移量 default is UIEdgeInsetZero
@property(nonatomic,assign) UIEdgeInsets ca_emptyViewInsets;

///当前是空数据 UIScrollView 一定是空的，其他的不一定
- (BOOL)isEmptyData;

@end

