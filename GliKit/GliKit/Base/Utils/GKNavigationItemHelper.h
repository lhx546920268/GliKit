//
//  GKNavigationItemHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/5.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///导航栏item帮助类
@interface GKNavigationItemHelper : NSObject

///关联的viewController
@property(nonatomic, weak, readonly) UIViewController *viewController;

///标题
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *viewControllerTitle;
@property(nonatomic, strong) UIView *titleView;

//返回按钮
@property(nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property(nonatomic, assign) BOOL hidesBackButton;

///左边item
@property(nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property(nonatomic, strong) NSArray<UIBarButtonItem*> *leftBarButtonItems;

///右边item
@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, strong) NSArray<UIBarButtonItem*> *rightBarButtonItems;

///设置导航栏隐藏item
@property(nonatomic, assign) BOOL hiddenItem;

///通过viewController 构建
- (instancetype)initWithViewController:(UIViewController*) viewController;

@end

