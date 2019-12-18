//
//  GKReactNativeReactNativeNestedScrollHelper.m
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKReactNativeNestedScrollHelper.h"
#import <objc/runtime.h>
#import <GKWeakObjectContainer.h>

@implementation GKReactNativeNestedScrollWeakContainer

@synthesize childScrollView = _childScrollView;

+ (instancetype)containerWithParent:(RCTScrollView *)view tag:(NSInteger)tag
{
    GKReactNativeNestedScrollWeakContainer *container = [GKReactNativeNestedScrollWeakContainer new];
    container.parentScrollView = view;
    container.tag = tag;
    
    return container;
}

- (RCTScrollView *)childScrollView
{
    if(!_childScrollView){
        UIView *view = [self.parentScrollView viewWithTag:self.tag];
        if([view isKindOfClass:RCTScrollView.class]){
            _childScrollView = (RCTScrollView*)view;
        }
    }
    return _childScrollView;
}

@end

@implementation GKReactNativeNestedScrollHelper

@synthesize childContainerScrollViews = _childContainerScrollViews;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parentScrollEnable = YES;
        self.childScrollEnable = YES;
    }
    return self;
}

- (UIScrollView *)parentScrollView
{
    return self.containerScrollView.scrollView;
}

- (NSArray<GKReactNativeNestedScrollWeakContainer *> *)childContainerScrollViews
{
    if(!_childContainerScrollViews && self.containerScrollView.nestedChildTags.count > 0){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.containerScrollView.nestedChildTags.count];
        for(NSNumber *tag in self.containerScrollView.nestedChildTags){
            [array addObject:[GKReactNativeNestedScrollWeakContainer containerWithParent:self.containerScrollView tag:tag.integerValue]];
        }
        _childContainerScrollViews = array;
    }
    
    return _childContainerScrollViews;
}

- (void)nestScrollDidScroll:(UIScrollView*) scrollView
{
    BOOL isParent = scrollView == self.parentScrollView;
    CGPoint contentOffset = scrollView.contentOffset;
    
    if(isParent){
        
        CGFloat maxOffsetY = floor(scrollView.contentSize.height - scrollView.frame.size.height);
        CGFloat offset = contentOffset.y - maxOffsetY;
        
        //已经滑出顶部范围了，让子容器滑动
        if(offset >= 0){
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            if(self.parentScrollEnable){
                self.parentScrollEnable = NO;
                self.childScrollEnable = YES;
            }
        }else{
            RCTCustomScrollView *parentScrollView = (RCTCustomScrollView*)scrollView;
            //不能让父容器继续滑动了
            if((!self.parentScrollEnable && parentScrollView.childScrollView.contentOffset.y > 0) || parentScrollView.childScrollView.containerScrollView.nestedChildRefreshEnable){
                scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            }
        }
        
    }else{
        
        //滚动容器还在滑动中
        CGFloat maxOffsetY = floor(self.parentScrollView.contentSize.height - self.parentScrollView.frame.size.height);
        if(!self.childScrollEnable || (self.parentScrollView.contentOffset.y > 0 && self.parentScrollView.contentOffset.y < maxOffsetY)){
            scrollView.contentOffset = CGPointZero;
            return;
        }
        
        //滑到滚动容器了滚动容器
        if(contentOffset.y < 0 && !self.containerScrollView.nestedChildRefreshEnable){
            scrollView.contentOffset = CGPointZero;
            if(self.parentScrollView.contentOffset.y > 0){
                self.childScrollEnable = NO;
                self.parentScrollEnable = YES;
            }
        }
    }
}

+ (RCTScrollView *)viewForTag:(NSInteger)tag inView:(UIView *)view
{
    if(view.superview == nil)
        return nil;
    if(view.superview.tag == tag && [view.superview isKindOfClass:RCTScrollView.class]){
        return (RCTScrollView*)view.superview;
    }else{
        return [GKReactNativeNestedScrollHelper viewForTag:tag inView:view.superview];
    }
}

@end


@implementation RCTScrollViewManager (GKReactNativeNestedScroll)

RCT_EXPORT_VIEW_PROPERTY(tag, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(iosReactNativeNestedScrollEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(nestedChildRefreshEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(nestedChildTags, NSArray)
RCT_EXPORT_VIEW_PROPERTY(nestedParentTag, NSInteger)

@end

static char GKChildScrollViewKey;

@implementation RCTCustomScrollView(GKReactNativeNestedScroll)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == self.panGestureRecognizer){
        RCTScrollView *scrollView = (RCTScrollView*)self.superview;
        if([scrollView isKindOfClass:RCTScrollView.class] && scrollView.iosReactNativeNestedScrollEnable && scrollView.nestedChildTags.count > 0){
            for(GKReactNativeNestedScrollWeakContainer *container in scrollView.nestedScrollHelper.childContainerScrollViews){
                if(container.childScrollView.scrollView.panGestureRecognizer == otherGestureRecognizer){
                    self.childScrollView = (RCTCustomScrollView*)container.childScrollView.scrollView;
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (RCTCustomScrollView *)childScrollView
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &GKChildScrollViewKey);
    return container.weakObject;
}

- (void)setChildScrollView:(RCTCustomScrollView *)childScrollView
{
    GKWeakObjectContainer *container = nil;
    if(childScrollView){
        container = [GKWeakObjectContainer containerWithObject:childScrollView];
    }
    objc_setAssociatedObject(self, &GKChildScrollViewKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RCTScrollView *)containerScrollView
{
    if([self.superview isKindOfClass:RCTScrollView.class])
        return (RCTScrollView*)self.superview;
    return nil;
}

@end

static char GKIosReactNativeNestedScrollEnableKey;
static char GKNestedChildTagsKey;
static char GKNestedChildRefreshEnableKey;
static char GKNestedParentTagKey;
static char GKNestedParentScrollViewKey;

@implementation RCTScrollView (GKReactNativeNestedScroll)

+ (void)load
{
    Method method1 = class_getInstanceMethod(self, @selector(scrollViewDidScroll:));
    Method method2 = class_getInstanceMethod(self, @selector(caReactNativeNestedScroll_scrollViewDidScroll:));
    method_exchangeImplementations(method1, method2);
}

- (BOOL)iosReactNativeNestedScrollEnable
{
    NSNumber *number = objc_getAssociatedObject(self, &GKIosReactNativeNestedScrollEnableKey);
    return number != nil ? number.boolValue : NO;
}

- (void)setIosReactNativeNestedScrollEnable:(BOOL)iosReactNativeNestedScrollEnable
{
    objc_setAssociatedObject(self, &GKIosReactNativeNestedScrollEnableKey, @(iosReactNativeNestedScrollEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSNumber *> *)nestedChildTags
{
    return objc_getAssociatedObject(self, &GKNestedChildTagsKey);
}

- (void)setNestedChildTags:(NSArray<NSNumber *> *)nestedChildTags
{
    objc_setAssociatedObject(self, &GKNestedChildTagsKey, nestedChildTags, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKReactNativeNestedScrollHelper *)nestedScrollHelper
{
    GKReactNativeNestedScrollHelper *helper = objc_getAssociatedObject(self, _cmd);
    if(!helper){
        helper = [GKReactNativeNestedScrollHelper new];
        helper.containerScrollView = self;
        objc_setAssociatedObject(self, _cmd, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return helper;
}

- (BOOL)nestedChildRefreshEnable
{
    NSNumber *number = objc_getAssociatedObject(self, &GKNestedChildRefreshEnableKey);
    return number != nil ? number.boolValue : NO;
}

- (void)setNestedChildRefreshEnable:(BOOL)nestedChildRefreshEnable
{
    objc_setAssociatedObject(self, &GKNestedChildRefreshEnableKey, @(nestedChildRefreshEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)nestedParentTag
{
    NSNumber *number = objc_getAssociatedObject(self, &GKNestedParentTagKey);
    return number != nil ? number.integerValue : 0;
}

- (void)setNestedParentTag:(NSInteger)nestedParentTag
{
    objc_setAssociatedObject(self, &GKNestedParentTagKey, @(nestedParentTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RCTScrollView *)nestedParentScrollView
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &GKNestedParentScrollViewKey);
    return container.weakObject;
}

- (void)setNestedParentScrollView:(RCTScrollView *)nestedParentScrollView
{
    GKWeakObjectContainer *container = nil;
    if(nestedParentScrollView){
        container = [GKWeakObjectContainer containerWithObject:nestedParentScrollView];
    }
    objc_setAssociatedObject(self, &GKNestedParentScrollViewKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)caReactNativeNestedScroll_scrollViewDidScroll:(UIScrollView *)scrollView
{
  if(self.iosReactNativeNestedScrollEnable){
      if(self.nestedChildTags.count > 0){
          [self.nestedScrollHelper nestScrollDidScroll:scrollView];
      }else if(self.nestedParentTag > 0){
          if(!self.nestedParentScrollView){
              self.nestedParentScrollView = [GKReactNativeNestedScrollHelper viewForTag:self.nestedParentTag inView:self];
          }
          [self.nestedParentScrollView.nestedScrollHelper nestScrollDidScroll:scrollView];
      }
  }
    [self caReactNativeNestedScroll_scrollViewDidScroll:scrollView];
}

@end
