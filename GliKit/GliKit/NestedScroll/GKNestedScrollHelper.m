//
//  GKNestedScrollHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKNestedScrollHelper.h"
#import <objc/runtime.h>

@implementation GKNestedScrollHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parentScrollEnable = YES;
        self.childScrollEnable = YES;
    }
    return self;
}

//MARK: 替换实现

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

//MARK: UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL isParent = scrollView == self.parentScrollView;
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat maxOffsetY = floor(self.parentScrollView.contentSize.height - self.parentScrollView.frame.size.height);
    if(isParent){
    
        CGFloat offset = contentOffset.y - maxOffsetY;
        
        //已经滑出顶部范围了，让子容器滑动
        if(offset >= 0){
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            if(self.parentScrollEnable){
                self.parentScrollEnable = NO;
                self.childScrollEnable = YES;
            }
        }else{
            //不能让父容器继续滑动了
            if(!self.parentScrollEnable){
                scrollView.contentOffset = CGPointMake(0, maxOffsetY);
            }
        }
        
    }else{
        
        //滚动容器还在滑动中
        if(!self.childScrollEnable || (self.parentScrollView.contentOffset.y > 0 && self.parentScrollView.contentOffset.y < maxOffsetY)){
            scrollView.contentOffset = CGPointZero;
            return;
        }
        
        //滑到滚动容器了滚动容器
        if(contentOffset.y <= 0){
            scrollView.contentOffset = CGPointZero;
            if(self.parentScrollView.contentOffset.y > 0){
                self.childScrollEnable = NO;
                self.parentScrollEnable = YES;
            }
        }
    }
}

@end
