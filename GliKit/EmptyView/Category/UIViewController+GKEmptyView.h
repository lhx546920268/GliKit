//
//  UIViewController+CAEmptyView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKEmptyView;

///空视图相关扩展
@interface UIViewController (CAEmptyView)

///空视图
@property(nonatomic,readonly) GKEmptyView *ca_emptyView;

///设置显示空视图
@property(nonatomic,assign) BOOL ca_showEmptyView;

@end

