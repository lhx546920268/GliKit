//
//  GKPageView.h
//  GliKit
//
//  Created by 罗海雄 on 2020/8/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPageView;

///翻页视图滑动方向
typedef NS_ENUM(NSInteger, GKPageViewScrollDirection){
    
    ///水平
    GKPageViewScrollDirectionHorizontal,
    
    ///垂直
    GKPageViewScrollDirectionVertical,
};

///翻页视图代理
@protocol GKPageViewDelegate <NSObject>

///Item数量
- (NSInteger)numberOfItemsInPageView:(GKPageView*) pageView;

///获取index对应的item
- (UIView*)pageView:(GKPageView*) pageView cellForItemAtIndex:(NSInteger) index;

@optional

///点击某个item了
- (void)pageView:(GKPageView*) pageView didSelectItemAtIndex:(NSInteger) index;

@end

///翻页视图
@interface GKPageView : UIView

///内部的ScrollView
@property(nonatomic, readonly) UIScrollView *scrollView;

///item占比，detault is `1.0`，值必须在 `0.1 ~ 1.0`
@property(nonatomic, assign) CGFloat ratio;

///item间隔，default is `0`
@property(nonatomic, assign) CGFloat spacing;

///次要的item 缩放比例 default is `1.0`，值必须在 `0.1 ~ 1.0`
@property(nonatomic, assign) CGFloat scale;

///是否可以循环滚动 default is 'YES' 1个cell时不循环
@property(nonatomic, assign) BOOL scrollInfinitely;

///当前位置
@property(nonatomic, readonly) NSInteger currentPage;

///播放间隔 default is '5.0'
@property(nonatomic, assign) NSTimeInterval playTimeInterval;

///是否自动播放 default is `YES`
@property(nonatomic, assign) BOOL autoPlay;

///代理
@property(nonatomic, weak) id<GKPageViewDelegate> delegate;


///注册cell
- (void)registerNib:(Class) cls;
- (void)registerClass:(Class) cls;

///复用cell
- (UIView*)dequeueCellForClass:(Class) cls forIndex:(NSInteger) index;

///重新加载数据
- (void)reloadData;

///滚动到指定的cell
- (void)scrollToIndex:(NSInteger) index animated:(BOOL) flag;

///通过下标获取 cell 如果cell是在可见范围内
- (__kindof UIView*)cellForIndex:(NSInteger) index;

///创建一个实例
- (instancetype)initWithScrollDirection:(GKPageViewScrollDirection) scrollDirection;

@end

NS_ASSUME_NONNULL_END
