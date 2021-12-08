//
//  CAReactNativeNestedScrollHelper.h
//  ZegoMart
//
//  Created by 罗海雄 on 2019/10/11.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTScrollViewManager.h>
#import <React/RCTScrollView.h>

///react-native scrollView 嵌套滚动

@interface CAWeakContainer : NSObject

///需要weak引用的对象
@property(nonatomic, weak) id weakObject;

+ (instancetype)containerWithObject:(id) object;

@end

//弱引用容器
@interface CANestedScrollWeakContainer : NSObject

///v
@property(nonatomic, weak, readonly) RCTScrollView *childScrollView;

///parent
@property(nonatomic, weak) RCTScrollView *parentScrollView;

@property(nonatomic, assign) NSInteger tag;


+ (instancetype)containerWithParent:(RCTScrollView*) view tag:(NSInteger) tag;

@end

@interface CANestedScrollHelper : NSObject

///父scrollView 是否可以滑动
@property(nonatomic, assign) BOOL parentScrollEnable;

///子scrollView 是否可以滑动
@property(nonatomic, assign) BOOL childScrollEnable;

///父容器
@property(nonatomic, weak) RCTScrollView *containerScrollView;

///需要嵌套滚动的子scrollView
@property(nonatomic, strong, readonly) NSArray<CANestedScrollWeakContainer*> *childContainerScrollViews;

///需要嵌套滚动的父scrollView
@property(nonatomic, weak, readonly) UIScrollView *parentScrollView;

///嵌套滑动代理
- (void)nestScrollDidScroll:(UIScrollView*) scrollView;

///
+ (RCTScrollView*)viewForTag:(NSInteger) tag inView:(UIView*) view;

@end

@interface RCTScrollViewManager (CANestedScroll)

@end

@interface RCTCustomScrollView(CANestedScroll)

///当前子滑动视图
@property (nonatomic, weak) RCTCustomScrollView *childScrollView;

///父容器
@property (nonatomic, weak, readonly) RCTScrollView *containerScrollView;

@end

@interface RCTScrollView (CANestedScroll)

/**
 * 是否支持嵌套滚动 嵌套滚动的容器设置此值
 */
@property (nonatomic, assign) BOOL iosNestedScrollEnable;
@property (nonatomic, strong) NSArray<NSNumber*> *nestedChildTags;
@property (nonatomic, readonly) CANestedScrollHelper *nestedScrollHelper;

///子scrollView 设置
@property (nonatomic, assign) BOOL nestedChildRefreshEnable; //设置后子scrollView 滑动顶部不会触发父scrollView 滑动
@property (nonatomic, assign) NSInteger nestedParentTag;
@property (nonatomic, weak) RCTScrollView *nestedParentScrollView;

@end

