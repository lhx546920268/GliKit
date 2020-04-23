//
//  GKNavigationBarTitleView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 iOS 11.0后 导航栏的标题栏， 在ios11后 导航栏的图层结构已发生变化，使用这个可以调整标题栏大小
 titleView内部有子视图使用约束时才需要
 */
@interface GKNavigationBarTitleView : UIView

/**
 内容视图 子视图都添加到这里
 */
@property(nonatomic, readonly) UIView *contentView;

/**
 内容大小 default is 'UILayoutFittingExpandedSize'
 */
@property(nonatomic, assign) CGSize contentSize;

/**
 关联的item
 */
@property(nonatomic, weak, readonly) UINavigationItem *navigationItem;

/**
 和导航栏按钮的间距
 */
@property(nonatomic, readonly) CGFloat marginForItem;

/**
 和屏幕的间距
 */
@property(nonatomic, readonly) CGFloat marginForScreen;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 通过导航栏item初始化
 */
- (instancetype)initWithNavigationItem:(UINavigationItem*) item NS_DESIGNATED_INITIALIZER;

@end

