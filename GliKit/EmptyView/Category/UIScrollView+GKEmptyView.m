//
//  UIScrollView+CAEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIScrollView+CAEmptyView.h"
#import "UIView+CAEmptyView.h"

///是否显示空视图kkey
static char CAShouldShowEmptyViewKey;

///偏移量
static char CAEmptyViewInsetsKey;

@implementation UIScrollView (CAEmptyView)

#pragma mark- swizzle

- (void)setCa_shouldShowEmptyView:(BOOL)ca_shouldShowEmptyView
{
    if(self.ca_shouldShowEmptyView != ca_shouldShowEmptyView)
    {
        objc_setAssociatedObject(self, &CAShouldShowEmptyViewKey, [NSNumber numberWithBool:ca_shouldShowEmptyView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if(ca_shouldShowEmptyView){
            [self layoutEmtpyView];
        }else{
            self.ca_emptyView = nil;
        }
    }
}

- (BOOL)ca_shouldShowEmptyView
{
    return [objc_getAssociatedObject(self, &CAShouldShowEmptyViewKey) boolValue];
}

- (void)setCa_emptyViewInsets:(UIEdgeInsets)ca_emptyViewInsets
{
    UIEdgeInsets insets = self.ca_emptyViewInsets;
    if(!UIEdgeInsetsEqualToEdgeInsets(insets, ca_emptyViewInsets))
    {
        objc_setAssociatedObject(self, &CAEmptyViewInsetsKey, [NSValue valueWithUIEdgeInsets:ca_emptyViewInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self layoutEmtpyView];
    }
}

- (UIEdgeInsets)ca_emptyViewInsets
{
    return [objc_getAssociatedObject(self, &CAEmptyViewInsetsKey) UIEdgeInsetsValue];
}


///调整emptyView
- (void)layoutEmtpyView
{
    if(!self.ca_shouldShowEmptyView)
        return;
    
    [self.superview layoutIfNeeded];
    //大小为0时不创建
    if(CGSizeEqualToSize(CGSizeZero, self.frame.size)){
        return;
    }
    
    if([self isEmptyData]){
        
        GKEmptyView *emptyView = self.ca_emptyView;
        if(!emptyView){
            emptyView = [GKEmptyView new];
            self.ca_emptyView = emptyView;
        }
        
        UIEdgeInsets insets = self.ca_emptyViewInsets;
        
        emptyView.frame = CGRectMake(insets.left, insets.top, self.mj_w - insets.left - insets.right, self.mj_h - insets.top - insets.bottom);
        emptyView.hidden = NO;
        
        if(!emptyView.superview){
            id<GKEmptyViewDelegate> delegate = self.ca_emptyViewDelegate;
            if([delegate respondsToSelector:@selector(emptyViewWillAppear:)]){
                [delegate emptyViewWillAppear:emptyView];
            }
            
            if(self.mj_footer){
                [self insertSubview:emptyView aboveSubview:self.mj_footer];
            }else{
                [self insertSubview:emptyView atIndex:0];
            }
        }
    }else{
        self.ca_emptyView = nil;
    }
}

///当前是空数据 UIScrollView 一定是空的，其他的不一定
- (BOOL)isEmptyData
{
    return YES;
}

@end
