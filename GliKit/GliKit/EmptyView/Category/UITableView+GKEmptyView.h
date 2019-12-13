//
//  UITableView+GKEmptyView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///用于UITableView的空视图扩展
@interface UITableView (GKEmptyView)

///存在 tableHeaderView 时，是否显示空视图 default is 'YES'
@property(nonatomic, assign) BOOL gkShouldShowEmptyViewWhenExistTableHeader;

///存在 tableFooterView 时，是否显示空视图 default is 'YES'
@property(nonatomic, assign) BOOL gkShouldShowEmptyViewWhenExistTableFooter;

///存在 sectionHeader 时，是否显示空视图 default is 'NO'
@property(nonatomic, assign) BOOL gkShouldShowEmptyViewWhenExistSectionHeader;

///存在 sectionFooter 时，是否显示空视图 default is 'NO'
@property(nonatomic, assign) BOOL gkShouldShowEmptyViewWhenExistSectionFooter;

@end

