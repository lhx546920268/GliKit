//
//  UIView+GKEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIView+CAEmptyView.h"
#import "GKWeakObjectContainer.h"

///空视图key
static char CAEmptyViewKey;

///代理
static char CAEmptyViewDelegateKey;

///显示空视图
static char CAShowEmptyViewKey;

///旧的视图大小
static char CAOldSizeKey;

@implementation UIView (CAEmptyView)


- (GKEmptyView*)ca_emptyView
{
    return objc_getAssociatedObject(self, &CAEmptyViewKey);;
}

- (void)setCa_emptyView:(GKEmptyView *)ca_emptyView
{
    UIView *emptyView = self.ca_emptyView;
    if(emptyView != ca_emptyView){
        [emptyView removeFromSuperview];
        objc_setAssociatedObject(self, &CAEmptyViewKey, ca_emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setCa_showEmptyView:(BOOL)ca_showEmptyView
{
    if(ca_showEmptyView != self.ca_showEmptyView){
        objc_setAssociatedObject(self, &CAShowEmptyViewKey, @(ca_showEmptyView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if(ca_showEmptyView){
            if(!self.ca_emptyView){
                self.ca_emptyView = [GKEmptyView new];
            }
            [self layoutEmtpyView];
        }else{
            self.ca_emptyView = nil;
        }
    }
}

- (BOOL)ca_showEmptyView
{
    return [objc_getAssociatedObject(self, &CAShowEmptyViewKey) boolValue];
}

- (void)setCa_emptyViewDelegate:(id<GKEmptyViewDelegate>)ca_emptyViewDelegate
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &CAEmptyViewDelegateKey);
    if(!container){
        container = [[GKWeakObjectContainer alloc] init];
    }
    
    container.weakObject = ca_emptyViewDelegate;
    objc_setAssociatedObject(self, &CAEmptyViewDelegateKey, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKEmptyViewDelegate>)ca_emptyViewDelegate
{
    GKWeakObjectContainer *container = objc_getAssociatedObject(self, &CAEmptyViewDelegateKey);
    return container.weakObject;
}

///调整emptyView
- (void)layoutEmtpyView
{
    if(self.ca_showEmptyView){
        GKEmptyView *emptyView = self.ca_emptyView;
        if(emptyView != nil && emptyView.superview == nil){
            id<GKEmptyViewDelegate> delegate = self.ca_emptyViewDelegate;
            if([delegate respondsToSelector:@selector(emptyViewWillAppear:)]){
                [delegate emptyViewWillAppear:emptyView];
            }
            [self addSubview:emptyView];
            
            [emptyView makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
                
                if([self isKindOfClass:[UIScrollView class]]){
                    make.size.equalTo(self);
                }
            }];
        }
    }
}

- (CGSize)ca_oldSize
{
    NSValue *value = objc_getAssociatedObject(self, &CAOldSizeKey);
    return !value ? CGSizeZero : [value CGSizeValue];
}

- (void)setCa_oldSize:(CGSize)ca_oldSize
{
    objc_setAssociatedObject(self, &CAOldSizeKey, [NSValue valueWithCGSize:ca_oldSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
