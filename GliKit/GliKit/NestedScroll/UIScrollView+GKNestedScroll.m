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

static char GKNestedScrollEnabledKey;
static char GKNestedParentKey;
static char GKChildDidScrollToParentKey;
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
    
    //如果没实现
    SEL selector1 = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
    if(![self respondsToSelector:selector1]){
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkNestedScrollAdd_%@", NSStringFromSelector(selector1)]);
        Method method = class_getInstanceMethod(self.class, selector2);
        class_addMethod(self, selector1, method_getImplementation(method), method_getTypeEncoding(method));
    }else{
        [self gkExchangeImplementations:selector1 prefix:prefix];
    }
}

///交换方法
- (void)gkNestedScrollSwizzle
{
    if(self.delegate && self.gkNestedScrollEnabled){
        [GKNestedScrollHelper replaceImplementations:@selector(scrollViewWillBeginDragging:) owner:self.delegate implementer:self];
        [GKNestedScrollHelper replaceImplementations:@selector(scrollViewDidScroll:) owner:self.delegate implementer:self];
        [GKNestedScrollHelper replaceImplementations:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:) owner:self.delegate implementer:self];
    }
}

// MARK: - Runtime

- (void)gkNestedScroll_setDelegate:(id<UIScrollViewDelegate>)delegate
{
    id oldDelegate = self.delegate;
    [self gkNestedScroll_setDelegate:delegate];
    if(oldDelegate != delegate){
        [self gkNestedScrollSwizzle];
    }
}

- (BOOL)gkNestedScroll_touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if(self.gkNestedScrollEnabled && self.gkNestedScrollHelper.autoScrolling){
        [self gkOnTouchScrollView];
        return NO;
    }
    return [self gkNestedScroll_touchesShouldBegin:touches withEvent:event inContentView:view];
}

///触摸了
- (void)gkOnTouchScrollView
{
    if(self.gkNestedScrollEnabled){
        [self.gkNestedScrollHelper onTouchScreen];
    }
}

// MARK: - UIScrollViewDelegate

- (void)gkNestedScrollAdd_scrollViewWillBeginDragging:(UIScrollView*) scrollView
{
    [scrollView gkOnTouchScrollView];
}

- (void)gkNestedScroll_scrollViewWillBeginDragging:(UIScrollView*) scrollView
{
    [scrollView gkOnTouchScrollView];
    [self gkNestedScroll_scrollViewWillBeginDragging:scrollView];
}

- (void)gkNestedScrollAdd_scrollViewDidScroll:(UIScrollView*) scrollView
{
    if(scrollView.gkNestedScrollEnabled){
        [scrollView.gkNestedScrollHelper scrollViewDidScroll:scrollView];
    }
}

- (void)gkNestedScroll_scrollViewDidScroll:(UIScrollView*) scrollView
{
    if(scrollView.gkNestedScrollEnabled){
        [scrollView.gkNestedScrollHelper scrollViewDidScroll:scrollView];
    }
    
    [self gkNestedScroll_scrollViewDidScroll:scrollView];
}

- (void)gkNestedScrollAdd_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView.gkNestedScrollEnabled && scrollView.gkNestedParent){
        [scrollView.gkNestedScrollHelper scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)gkNestedScroll_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(scrollView.gkNestedScrollEnabled){
        [scrollView.gkNestedScrollHelper scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
 
    [self gkNestedScroll_scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

// MARK: - Gesture

- (BOOL)gkNestedScrollAdd_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //只有平移手势才允许手势冲突
    if(gestureRecognizer == self.panGestureRecognizer && self.gkNestedParent){
        return otherGestureRecognizer == self.gkNestedChildScrollView.panGestureRecognizer;
    }
    return NO;
}

///允许手势冲突
- (BOOL)gkNestedScroll_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //只有平移手势才允许手势冲突
    if(gestureRecognizer == self.panGestureRecognizer && self.gkNestedParent){
        return otherGestureRecognizer == self.gkNestedChildScrollView.panGestureRecognizer;
    }
    return [self gkNestedScroll_gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

// MARK: - Props

- (void)setGkNestedScrollEnabled:(BOOL) enabled
{
    objc_setAssociatedObject(self, &GKNestedScrollEnabledKey, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self gkNestedScrollSwizzle];
}

- (BOOL)gkNestedScrollEnabled
{
    return [objc_getAssociatedObject(self, &GKNestedScrollEnabledKey) boolValue];
}

- (void)setGkNestedParent:(BOOL)gkNestedParent
{
    objc_setAssociatedObject(self, &GKNestedParentKey, @(gkNestedParent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gkNestedParent
{
    return [objc_getAssociatedObject(self, &GKNestedParentKey) boolValue];
}

- (void (^)(void))gkChildDidScrollToParent
{
    return objc_getAssociatedObject(self, &GKChildDidScrollToParentKey);
}

- (void)setGkChildDidScrollToParent:(void (^)(void))gkChildDidScrollToParent
{
    objc_setAssociatedObject(self, &GKChildDidScrollToParentKey, gkChildDidScrollToParent, OBJC_ASSOCIATION_COPY_NONATOMIC);
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
    [self.gkNestedScrollHelper checkScrollEnabled];
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
        parent = self.gkNestedParentScrollView;
        helper = objc_getAssociatedObject(parent, &GKNestedScrollHelperKey);
    }
    if(!helper){
        helper = [GKNestedScrollHelper new];
        if(isParent){
            helper.parentScrollView = self;
            objc_setAssociatedObject(self, &GKNestedScrollHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if (parent) {
            helper.parentScrollView = parent;
            objc_setAssociatedObject(parent, &GKNestedScrollHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return helper;
}

@end
