//
//  GKNestedScrollHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

///嵌套滑动帮助类
@interface GKNestedScrollHelper : NSObject<UIScrollViewDelegate>

///父scrollView 是否可以滑动
@property(nonatomic, assign) BOOL parentScrollEnabled;

///子scrollView 是否可以滑动
@property(nonatomic, assign) BOOL childScrollEnabled;

///父容器
@property(nonatomic, weak, nullable) UIScrollView *parentScrollView;

///是否正在模拟系统自动滑动
@property(nonatomic, readonly) BOOL autoScrolling;

///校验哪个可以滑动
- (void)checkScrollEnabled;

///用户触摸屏幕了
- (void)onTouchScreen;

/// 替换某个方法的实现 新增的方法要加一个前缀gkNestedScroll
/// @param selector 要替换的方法
/// @param owner 方法的拥有者
/// @param implementer 新方法的实现者
+ (void)replaceImplementations:(SEL) selector owner:(NSObject*) owner implementer:(NSObject*) implementer;

@end

NS_ASSUME_NONNULL_END

