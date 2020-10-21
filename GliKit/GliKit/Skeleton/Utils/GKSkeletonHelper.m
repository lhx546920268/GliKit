//
//  GKSkeletonHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKSkeletonHelper.h"
#import "GKSkeletonSubLayer.h"
#import "UIView+GKSkeleton.h"
#import "UIColor+GKUtils.h"
#import <objc/runtime.h>

@implementation GKSkeletonHelper

+ (BOOL)shouldBecomeSkeleton:(UIView *)view
{
    if(view.hidden || view.alpha <= 0.01){
        return NO;
    }
    
    if([view isMemberOfClass:UIView.class] && (!view.backgroundColor || [view.backgroundColor isEqualToColor:UIColor.clearColor])){
        return NO;
    }
    
    return [view isKindOfClass:UILabel.class] || [view isKindOfClass:UIImageView.class] || [view isKindOfClass:UIButton.class];
}

+ (void)createLayers:(NSMutableArray *)layers fromView:(UIView *)view rootView:(UIView *)rootView
{
    NSArray *subviews = view.subviews;
    
    if(subviews.count > 0){
        for(UIView *subview in subviews){
            
            [self createLayers:layers fromView:subview rootView:rootView];
        }
    }else if(view != rootView){
        
        if(!view.gkShouldBecomeSkeleton)
            return;
        
        CGRect rect;
        if(view.superview == rootView){
            rect = view.frame;
        }else{
            rect = [view.superview convertRect:view.frame toView:rootView];
        }
        
        GKSkeletonSubLayer *layer = [GKSkeletonSubLayer layer];
        layer.frame = rect;
        [layer copyPropertiesFromLayer:view.layer];
        [layers addObject:layer];
    }
}

// MARK: - 替换实现

+ (void)replaceImplementations:(SEL) selector owner:(NSObject *)owner implementer:(NSObject *)implementer
{
    if([owner respondsToSelector:selector]){
        Method method1 = class_getInstanceMethod(owner.class, selector);
        SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkSkeleton_%@", NSStringFromSelector(selector)]);
        
        //给代理 添加一个 方法名为 gkSkeleton_ 前缀的，但是实现还是 代理的实现的方法
        if(class_addMethod(owner.class, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))){
            
            //替换代理中的方法为 gkSkeleton_ 前缀的方法
            Method method2 = class_getInstanceMethod(implementer.class, selector2);
            class_replaceMethod(owner.class, selector, method_getImplementation(method2), method_getTypeEncoding(method2));
        }
    }else{
        
        //让UITableView UICollectionView 在显示骨架过程中不能点击 cell
        if(selector == @selector(tableView:shouldHighlightRowAtIndexPath:) || selector == @selector(collectionView:shouldHighlightItemAtIndexPath:)){
            SEL selector2 = NSSelectorFromString([NSString stringWithFormat:@"gkSkeletonAdd_%@", NSStringFromSelector(selector)]);
            Method method = class_getInstanceMethod(implementer.class, selector2);
            class_addMethod(owner.class, selector, method_getImplementation(method), method_getTypeEncoding(method));
        }
    }
}

@end
