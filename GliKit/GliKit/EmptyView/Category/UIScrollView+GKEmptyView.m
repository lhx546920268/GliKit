//
//  UIScrollView+GKEmptyView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIScrollView+GKEmptyView.h"
#import "UIView+GKEmptyView.h"
#import <objc/runtime.h>
#import "UIView+GKUtils.h"
#import "UIScrollView+GKRefresh.h"
#import "GKLoadMoreControl.h"
#import "NSObject+GKUtils.h"

///是否显示空视图kkey
static char GKShouldShowEmptyViewKey;

///偏移量
static char GKEmptyViewInsetsKey;

static char GKEmptyHelperKey;

///空视图帮助类
@interface GKEmptyHelper : NSObject

@property(nonatomic, weak) UIScrollView *scrollView;
@property(nonatomic, assign) CGSize contentSize;

- (instancetype)initWithScrollView:(UIScrollView*) scrollView;

@end

static void* const GKEmptyHelperContext = "GKEmptyHelperContext";

@implementation GKEmptyHelper

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if(self){
        self.scrollView = scrollView;
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:GKEmptyHelperContext];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == GKEmptyHelperContext) {
        if(!CGSizeEqualToSize(self.contentSize, self.scrollView.contentSize)){
            self.contentSize = self.scrollView.contentSize;
            [self.scrollView layoutEmtpyView];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:GKEmptyHelperContext];
    }
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize" context:@"GKEmptyHelperContext"];
}

@end

@implementation UIScrollView (GKEmptyView)

- (void)setGkShouldShowEmptyView:(BOOL)gkShouldShowEmptyView
{
    if(self.gkShouldShowEmptyView != gkShouldShowEmptyView){
        objc_setAssociatedObject(self, &GKShouldShowEmptyViewKey, @(gkShouldShowEmptyView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if(gkShouldShowEmptyView){
            [self gkEnsureEmptyHelper];
            [self layoutEmtpyView];
        }else{
            [self setGkEmptyHelper:nil];
            self.gkEmptyView = nil;
        }
    }
}

- (BOOL)gkShouldShowEmptyView
{
    return [objc_getAssociatedObject(self, &GKShouldShowEmptyViewKey) boolValue];
}

- (void)setGkEmptyHelper:(GKEmptyHelper*) helper
{
    objc_setAssociatedObject(self, &GKEmptyHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)gkEnsureEmptyHelper
{
    GKEmptyHelper *helper = objc_getAssociatedObject(self, &GKEmptyHelperKey);
    if(!helper){
        helper = [[GKEmptyHelper alloc] initWithScrollView:self];
        [self setGkEmptyHelper:helper];
    }
}

- (void)setGkEmptyViewInsets:(UIEdgeInsets)gkEmptyViewInsets
{
    UIEdgeInsets insets = self.gkEmptyViewInsets;
    if(!UIEdgeInsetsEqualToEdgeInsets(insets, gkEmptyViewInsets))
    {
        objc_setAssociatedObject(self, &GKEmptyViewInsetsKey, @(gkEmptyViewInsets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self layoutEmtpyView];
    }
}

- (UIEdgeInsets)gkEmptyViewInsets
{
    return [objc_getAssociatedObject(self, &GKEmptyViewInsetsKey) UIEdgeInsetsValue];
}

///调整emptyView
- (void)layoutEmtpyView
{
    if(!self.gkShouldShowEmptyView)
        return;
    
    //大小为0时不创建
    if(CGSizeEqualToSize(CGSizeZero, self.frame.size)){
        return;
    }
    
    if([self gkIsEmptyData]){
        
        GKEmptyView *emptyView = self.gkEmptyView;
        if(!emptyView){
            emptyView = [GKEmptyView new];
            self.gkEmptyView = emptyView;
        }
        
        UIEdgeInsets insets = self.gkEmptyViewInsets;
        
        emptyView.frame = CGRectMake(insets.left, insets.top, self.gkWidth - insets.left - insets.right, self.gkHeight - insets.top - insets.bottom);
        emptyView.hidden = NO;
        
        if(!emptyView.superview){
            id<GKEmptyViewDelegate> delegate = self.gkEmptyViewDelegate;
            if([delegate respondsToSelector:@selector(emptyViewWillAppear:)]){
                [delegate emptyViewWillAppear:emptyView];
            }
            
            if(self.gkLoadMoreControl){
                [self insertSubview:emptyView aboveSubview:self.gkLoadMoreControl];
            }else{
                [self insertSubview:emptyView atIndex:0];
            }
        }
    }else{
        self.gkEmptyView = nil;
    }
}

///当前是空数据 UIScrollView 一定是空的，其他的不一定
- (BOOL)gkIsEmptyData
{
    return YES;
}

@end
