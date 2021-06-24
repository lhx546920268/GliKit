//
//  GKIndexSearchBar.h
//  GliKit
//
//  Created by 罗海雄 on 2021/6/21.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

///索引搜索，类似UITableView 的 indexTitle
@interface GKIndexSearchBar : UIView

///标题
@property(nonatomic, copy) NSArray<NSString*> *indexTitles;

///当前选中的
@property(nonatomic, assign) NSUInteger selectedIndex;

///改变了
@property(nonatomic, copy) void (^indexDidChange)(NSUInteger index, NSString *title);

@end

