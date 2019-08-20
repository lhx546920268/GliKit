//
//  GKEmptyView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKEmptyView;

///空视图代理
@protocol GKEmptyViewDelegate <NSObject>

@optional

///空视图图标
- (void)emptyViewWillAppear:(GKEmptyView*) view;

@end

///数据为空的视图
@interface GKEmptyView : UIView

///图标
@property(nonatomic,readonly) UIImageView *iconImageView;

///文字信息
@property(nonatomic,readonly) UILabel *textLabel;

///自定义视图 如果设置将忽略以上两个，并且会重新设置customView的约束，高度约束和frame.size.height一样
@property(nonatomic,strong) UIView *customView;

@end
