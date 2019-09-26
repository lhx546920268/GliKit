//
//  GKNavigationItemHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/5.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///导航栏item帮助类
@interface GKNavigationItemHelper : NSObject

///关联的viewController
@property(nonatomic, weak, readonly, nullable) UIViewController *viewController;

///标题
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *viewControllerTitle;
@property(nonatomic, strong, nullable) UIView *titleView;

//返回按钮
@property(nonatomic, strong, nullable) UIBarButtonItem *backBarButtonItem;
@property(nonatomic, assign) BOOL hidesBackButton;

///左边item
@property(nonatomic, strong, nullable) UIBarButtonItem *leftBarButtonItem;
@property(nonatomic, strong, nullable) NSArray<UIBarButtonItem*> *leftBarButtonItems;

///右边item
@property(nonatomic, strong, nullable) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, strong, nullable) NSArray<UIBarButtonItem*> *rightBarButtonItems;

///设置导航栏隐藏item
@property(nonatomic, assign) BOOL hiddenItem;

///通过viewController 构建
- (instancetype)initWithViewController:(UIViewController*) viewController;

@end

NS_ASSUME_NONNULL_END

