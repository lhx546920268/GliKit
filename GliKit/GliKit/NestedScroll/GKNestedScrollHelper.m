//
//  GKNestedScrollHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKNestedScrollHelper.h"
#import <objc/runtime.h>
#import "GKWeakProxy.h"
#import "UIView+GKUtils.h"
#import "UIScrollView+GKNestedScroll.h"
#import "UIScrollView+GKRefresh.h"

///手动设置contentOffset状态
typedef NS_ENUM(NSInteger, GKNestedScrollContentOffsetStatus){
    
    ///什么都没
    GKNestedScrollContentOffsetStatusNone,
    
    ///开始自动设置contentOffset
    GKNestedScrollContentOffsetStatusBegan,
    
    ///offset的范围已经超出contentSize了， 慢慢向前进，达到一定值回弹
    GKNestedScrollContentOffsetStatusBounceForward,
    
    ///回弹了
    GKNestedScrollContentOffsetStatusBounceBack,
};

///减速衰减比例
static const CGFloat GKNestedScrollSlowDampingRaito = 0.81f;

@interface GKNestedScrollHelper ()

///监听屏幕刷新
@property(nonatomic, strong) CADisplayLink *displayLink;

///当前滑动状态
@property(nonatomic, assign) GKNestedScrollContentOffsetStatus status;

///父容器最大滑动位置
@property(nonatomic, assign) CGFloat parentMaxOffset;

///每帧 毫秒数
@property(nonatomic, assign) NSTimeInterval timePerFrame;

///当前速度
@property(nonatomic, assign) CGFloat currentSpeed;

///帧数
@property(nonatomic, assign) int frames;

@end

@implementation GKNestedScrollHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parentScrollEnabled = YES;
        self.childScrollEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [self stopDisplayLink];
}

- (BOOL)autoScrolling
{
    return self.displayLink != nil;
}

- (void)onTouchScreen
{
    [self stopDisplayLink];
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat maxOffsetY = floor(self.parentScrollView.contentSize.height - self.parentScrollView.gkHeight);
    UIScrollView *child = self.parentScrollView.gkNestedChildScrollView;
    
    if(maxOffsetY <= 0 || !child || child.contentSize.height == 0)
        return;
    
    BOOL isParent = scrollView == self.parentScrollView;
    CGPoint contentOffset = scrollView.contentOffset;
    if(isParent){
    
        BOOL childRefreshEnable = child.gkRefreshControl != nil;
        
        //下拉刷新中
        if(child.contentOffset.y < 0 && childRefreshEnable){
            scrollView.contentOffset = CGPointZero;
            return;
        }
        
        CGFloat offset = contentOffset.y - maxOffsetY;
        
        //已经滑出顶部范围了，让子容器滑动
        if(offset >= 0){
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            if(self.parentScrollEnabled){
                self.parentScrollEnabled = NO;
                self.childScrollEnabled = YES;
            }
        }else{
            //不能让父容器继续滑动了
            if(!self.parentScrollEnabled){
                scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            }
        }
        
        //到顶部了，应该要下拉刷新了
        if(scrollView.contentOffset.y <= 0){
    
            if(childRefreshEnable){
                self.childScrollEnabled = YES;
                scrollView.contentOffset = CGPointZero;
            }
        }
        
    }else{
        
        BOOL enabled = scrollView.gkRefreshControl != nil ? self.parentScrollView.contentOffset.y > 0 : YES;
        //滚动容器还在滑动中
        if(!self.childScrollEnabled || (enabled && self.parentScrollView.contentOffset.y < maxOffsetY)){
            scrollView.contentOffset = CGPointZero;
            return;
        }
        
        //滑到滚动容器了滚动容器
        if(contentOffset.y <= 0 && self.parentScrollView.contentOffset.y > 0){
            scrollView.contentOffset = CGPointZero;
            self.childScrollEnabled = NO;
            self.parentScrollEnabled = YES;
            if(self.parentScrollView.gkChildDidScrollToParent){
                self.parentScrollView.gkChildDidScrollToParent();
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //主要是为了 滑动父容器时 可以促使child滑动 只有向下滑动时才需要
    CGFloat maxOffsetY = floor(scrollView.contentSize.height - scrollView.gkHeight);
    if(velocity.y <= 0 || scrollView.contentOffset.y >= maxOffsetY){
        return;
    }
    
    NSInteger i = 0;
    CGFloat speed = velocity.y;
    while (speed > 0.01) {
        
        speed *= GKNestedScrollSlowDampingRaito;
        i ++;
    }
    
    //估算滑动距离超过容器可滑动距离的最大值时，模拟系统的滑动
    //解决当快速滑动的时候 两个ScrollView 不连贯的问题
    if(floor(i * 100.0f * velocity.y + scrollView.contentOffset.y) > maxOffsetY){
        //模拟系统的滑动减速衰减
        self.parentMaxOffset = maxOffsetY;
        self.status = GKNestedScrollContentOffsetStatusBegan;
        self.frames = 0;
        self.currentSpeed = velocity.y;
        *targetContentOffset = scrollView.contentOffset;
        
        [self startDisplayLink];
    }
}

// MARK: - Display Link

///开始监听屏幕刷新
- (void)startDisplayLink
{
    [self stopDisplayLink];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:[GKWeakProxy weakProxyWithTarget:self] selector:@selector(handleLink)];
    //60FPS
    self.timePerFrame = 17;
    [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

///停止监听
- (void)stopDisplayLink
{
    if(self.displayLink){
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

///处理屏幕刷新
- (void)handleLink
{
    //每帧 毫秒数
    self.frames ++;
    if(self.frames * self.timePerFrame >= 100){
        //每100毫秒衰减一次
        self.frames = 0;
        self.currentSpeed *= GKNestedScrollSlowDampingRaito;
    }
    
    //速度低于这个值就停止了
    if(self.currentSpeed <= 0.01){
        [self stopDisplayLink];
        return;
    }
    
    //父容器滑动到最大值后就滑动child
    if(self.parentScrollView.contentOffset.y >= self.parentMaxOffset){
        UIScrollView *scrollView = self.parentScrollView.gkNestedChildScrollView;
        CGFloat y = scrollView.contentOffset.y + self.currentSpeed * self.timePerFrame;
        CGPoint contentOffset = scrollView.contentOffset;
        CGFloat max = scrollView.contentSize.height + scrollView.contentInset.bottom;
        if(y + scrollView.gkHeight >= max){
            y = max - scrollView.gkHeight;
            [self stopDisplayLink];
        }
        contentOffset.y = y;
        scrollView.contentOffset = contentOffset;
    }else{
        CGFloat y = self.parentScrollView.contentOffset.y + self.currentSpeed * self.timePerFrame;
        CGPoint contentOffset = self.parentScrollView.contentOffset;
        contentOffset.y = MIN(self.parentMaxOffset, y);
        self.parentScrollView.contentOffset = contentOffset;
    }
}

// MARK: - 替换实现

+ (void)replaceImplementations:(SEL) selector owner:(NSObject *)owner implementer:(NSObject *)implementer
{
    if([owner respondsToSelector:selector]){
        
        Method method1 = class_getInstanceMethod(owner.class, selector);
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkNestedScroll_%@", NSStringFromSelector(selector)]);
        
        //给代理 添加一个 方法名为 gkNestedScroll_ 前缀的，但是实现还是 代理的实现的方法
        if(class_addMethod(owner.class, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))){
            
            //替换代理中的方法为 gkNestedScroll_ 前缀的方法
            Method method2 = class_getInstanceMethod(implementer.class, selector2);
            class_replaceMethod(owner.class, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        }
    }else{
        
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkNestedScrollAdd_%@", NSStringFromSelector(selector)]);
        Method method = class_getInstanceMethod(implementer.class, selector2);
        class_addMethod(owner.class, selector, method_getImplementation(method), method_getTypeEncoding(method));
    }
}

@end
