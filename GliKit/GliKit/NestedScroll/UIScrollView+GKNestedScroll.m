//
//  UIScrollView+GKNestedScroll.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIScrollView+GKNestedScroll.h"
#import "NSObject+GKUtils.h"
#import "GKNestedScrollHelper.h"
#import <objc/runtime.h>
#import "GKWeakObjectContainer.h"
#import "GKNestedScrollHelper.h"

static char GKNestedScrollEnableKey;
static char GKNestedParentKey;
static char GKNestedParentScrollViewKey;
static char GKNestedChildScrollViewKey;
static char GKNestedScrollHelperKey;

///找到嵌套滑动容器
static UIScrollView* GKFindNestedParentScrollView(UIView *child)
{
    if(child.superview == nil)
        return nil;
    
    UIScrollView *scrollView = (UIScrollView*)child.superview;
    if([scrollView isKindOfClass:UIScrollView.class] && scrollView.gkNestedParent){
        return scrollView;
    }else{
        return GKFindNestedParentScrollView(scrollView);
    }
}

@implementation UIScrollView (GKNestedScroll)

+ (void)load
{
    NSString *prefix = @"gkNestedScroll_";
    [self gkExchangeImplementations:@selector(setDelegate:) prefix:prefix];
    [self gkExchangeImplementations:@selector(touchesShouldBegin:withEvent:inContentView:) prefix:prefix];
}

//MARK: Runtime

- (void)gkNestedScroll_setDelegate:(id<UIScrollViewDelegate>)delegate
{
    if(delegate){
        [GKNestedScrollHelper replaceImplementations:@selector(scrollViewDidScroll:) owner:delegate implementer:self];
        [GKNestedScrollHelper replaceImplementations:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:) owner:delegate implementer:self];
    }
    [self gkNestedScroll_setDelegate:delegate];
}

- (BOOL)gkNestedScroll_touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if(self.gkNestedScrollEnable && self.gkNestedScrollHelper.gkAutoScrolling){
        [self gkOnTouchScrollView];
        return NO;
    }
    return [self gkNestedScroll_touchesShouldBegin:touches withEvent:event inContentView:view];
}

///触摸了
- (void)gkOnTouchScrollView
{
    if(self.gkNestedScrollEnable){
        [self.gkNestedScrollHelper onTouchScreen];
    }
}

//MARK: UIScrollViewDelegate

- (void)gkNestedScrollAdd_scrollViewDidScroll:(UIScrollView*) scrollView
{
    if(scrollView.gkNestedScrollEnable){
        [scrollView.gkNestedScrollHelper scrollViewDidScroll:scrollView];
    }
}

- (void)gkNestedScroll_scrollViewDidScroll:(UIScrollView*) scrollView
{
    if(scrollView.gkNestedScrollEnable){
        [scrollView.gkNestedScrollHelper scrollViewDidScroll:scrollView];
    }
    //调用 代理自己的实现
    [self gkNestedScroll_scrollViewDidScroll:scrollView];
}

- (void)gkNestedScrollAdd_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView.gkNestedScrollEnable && scrollView.gkNestedParent){
        [scrollView.gkNestedScrollHelper scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)gkNestedScroll_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView.gkNestedScrollEnable && scrollView.gkNestedParent){
        [scrollView.gkNestedScrollHelper scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
 
    [self gkNestedScroll_scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

//MARK: Gesture

///允许手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //只有平移手势才允许手势冲突
    if(self.gkNestedParent && gestureRecognizer == self.panGestureRecognizer){
        return otherGestureRecognizer == self.gkNestedChildScrollView.panGestureRecognizer;
    }
    return NO;
}

//MARK: Props

- (void)setGkNestedScrollEnable:(BOOL)gkNestedScrollEnable
{
    objc_setAssociatedObject(self, &GKNestedScrollEnableKey, @(gkNestedScrollEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkNestedScrollEnable
{
    return [objc_getAssociatedObject(self, &GKNestedScrollEnableKey) boolValue];
}

- (void)setGkNestedParent:(BOOL)gkNestedParent
{
    objc_setAssociatedObject(self, &GKNestedParentKey, @(gkNestedParent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkNestedParent
{
    return [objc_getAssociatedObject(self, &GKNestedParentKey) boolValue];
}

- (void)setGkNestedParentScrollView:(UIScrollView *)gkNestedParentScrollView
{
    objc_setAssociatedObject(self, &GKNestedParentScrollViewKey, [GKWeakObjectContainer containerWithObject:gkNestedParentScrollView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)gkNestedParentScrollView
{
    UIScrollView *scrollView = [objc_getAssociatedObject(self, &GKNestedParentScrollViewKey) weakObject];
    if(!scrollView){
        scrollView = GKFindNestedParentScrollView(self);
        [self setGkNestedParentScrollView:scrollView];
    }
    return scrollView;
}

- (void)setGkNestedChildScrollView:(UIScrollView *)gkNestedChildScrollView
{
    objc_setAssociatedObject(self, &GKNestedChildScrollViewKey, [GKWeakObjectContainer containerWithObject:gkNestedChildScrollView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)gkNestedChildScrollView
{
    return [objc_getAssociatedObject(self, &GKNestedChildScrollViewKey) weakObject];
}

- (GKNestedScrollHelper *)gkNestedScrollHelper
{
    GKNestedScrollHelper *helper = nil;
    UIScrollView *parent = nil;
    BOOL isParent = self.gkNestedParent;
    if(isParent){
        helper = objc_getAssociatedObject(self, &GKNestedScrollHelperKey);
    }else{
        parent = self.gkNestedParentScrollView;;
        helper = objc_getAssociatedObject(parent, &GKNestedScrollHelperKey);
    }
    if(!helper){
        helper = [GKNestedScrollHelper new];
        if(isParent){
            helper.parentScrollView = self;
            objc_setAssociatedObject(self, &GKNestedScrollHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else{
            helper.parentScrollView = parent;
            objc_setAssociatedObject(parent, &GKNestedScrollHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return helper;
}

@end
