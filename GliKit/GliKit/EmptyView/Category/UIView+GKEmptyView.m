//
//  UIView+GKEmptyView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKEmptyView.h"
#import "GKWeakObjectContainer.h"
#import <objc/runtime.h>
#import "GKBaseDefines.h"

///空视图key
static char GKEmptyViewKey;

///代理
static char GKEmptyViewDelegateKey;

///显示空视图
static char GKShowEmptyViewKey;

///旧的视图大小
static char GKOldSizeKey;

@implementation UIView (GKEmptyView)

- (GKEmptyView*)gkEmptyView
{
    return objc_getAssociatedObject(self, &GKEmptyViewKey);;
}

- (void)setGkEmptyView:(GKEmptyView *)gkEmptyView
{
    UIView *emptyView = self.gkEmptyView;
    if(emptyView != gkEmptyView){
        [emptyView removeFromSuperview];
        objc_setAssociatedObject(self, &GKEmptyViewKey, gkEmptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setGkShowEmptyView:(BOOL)gkShowEmptyView
{
    if(gkShowEmptyView != self.gkShowEmptyView){
        objc_setAssociatedObject(self, &GKShowEmptyViewKey, @(gkShowEmptyView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if(gkShowEmptyView){
            if(!self.gkEmptyView){
                self.gkEmptyView = [GKEmptyView new];
            }
            [self layoutEmtpyView];
        }else{
            self.gkEmptyView = nil;
        }
    }
}

- (BOOL)gkShowEmptyView
{
    return [objc_getAssociatedObject(self, &GKShowEmptyViewKey) boolValue];
}

- (void)setGkEmptyViewDelegate:(id<GKEmptyViewDelegate>)gkEmptyViewDelegate
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &GKEmptyViewDelegateKey);
    if(gkEmptyViewDelegate && !container){
        container = [[GKWeakObjectContainer alloc] init];
    }
    
    container.weakObject = gkEmptyViewDelegate;
    objc_setAssociatedObject(self, &GKEmptyViewDelegateKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKEmptyViewDelegate>)gkEmptyViewDelegate
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &GKEmptyViewDelegateKey);
    return container.weakObject;
}

///调整emptyView
- (void)layoutEmtpyView
{
    if(self.gkShowEmptyView){
        GKEmptyView *emptyView = self.gkEmptyView;
        if(emptyView != nil && emptyView.superview == nil){
            id<GKEmptyViewDelegate> delegate = self.gkEmptyViewDelegate;
            if([delegate respondsToSelector:@selector(emptyViewWillAppear:)]){
                [delegate emptyViewWillAppear:emptyView];
            }
            [self addSubview:emptyView];
            
            [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
}

- (CGSize)gkOldSize
{
    NSValue *value = objc_getAssociatedObject(self, &GKOldSizeKey);
    return !value ? CGSizeZero : [value CGSizeValue];
}

- (void)setGkOldSize:(CGSize)gkOldSize
{
    objc_setAssociatedObject(self, &GKOldSizeKey, [NSValue valueWithCGSize:gkOldSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
