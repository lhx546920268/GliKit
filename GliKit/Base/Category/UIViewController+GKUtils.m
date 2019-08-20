//
//  UIViewController+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+GKUtils.h"
#import <objc/runtime.h>
#import "GKBaseNavigationController.h"
#import "UINavigationBar+GKUtils.h"

/**
 返回按钮
 */
static char GKBackItemViewKey;

/**
 是否可以活动返回
 */
static char GKInteractivePopEnableKey;

@implementation UIViewController (Utils)

- (void)setCa_hideNavigationBarShadowImage:(BOOL)gk_hideNavigationBarShadowImage
{
    UIImageView *shadowImageView = [self gk_findShadowImageView:self.navigationController.navigationBar];
    shadowImageView.hidden = gk_hideNavigationBarShadowImage;
}

- (UIImageView*)gk_findShadowImageView:(UIView*)view
{
    if([view isKindOfClass:[UIImageView class]] && view.bounds.size.height <= 1.0){
        return (UIImageView*) view;
    }
    
    for(UIView *subView in view.subviews){
        UIImageView *imageView = [self gk_findShadowImageView:subView];
        if(imageView){
            return imageView;
        }
    }
    
    return nil;
}

//设置返回按钮
- (void)setCa_showBackItem:(BOOL)gk_showBackItem
{
    if(gk_showBackItem){
        UIImage *image = [UIImage imageNamed:@"nav_btn_back_white"];
        //Template
        if(image.renderingMode != UIImageRenderingModeAlwaysTemplate){
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        UIBarButtonItem *item = [[self class] gk_barItemWithImage:image target:self action:@selector(gk_back)];
        item.customView.tag = GKBackItemTag;
        objc_setAssociatedObject(self, &GKBackItemViewKey, item.customView, OBJC_ASSOCIATION_RETAIN);
        [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.hidesBackButton = YES;
        objc_setAssociatedObject(self, &GKBackItemViewKey, nil, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIView *)gk_backItem
{
    return objc_getAssociatedObject(self, &GKBackItemViewKey);
}

- (BOOL)gk_showBackItem
{
    return self.navigationItem.leftBarButtonItem.customView.tag == GKBackItemTag;
}

- (void)gk_back
{
    [self gk_backAnimated:YES];
}

- (void)gk_backAnimated:(BOOL) flag
{
    [self gk_backAnimated:flag completion:nil];
}

- (void)gk_backAnimated:(BOOL) flag completion: (void (^)(void))completion
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    if(self.navigationController.viewControllers.count <= 1){
        if(self.presentingViewController){
            [self dismissViewControllerAnimated:flag completion:completion];
        }else{
            !completion ?: completion();
        }
    }else{
        [self.navigationController popViewControllerAnimated:flag && !completion];
        !completion ?: completion();
    }
}

- (BOOL)gk_interactivePopEnable
{
    NSNumber *number = objc_getAssociatedObject(self, &GKInteractivePopEnableKey);
    return number ? number.boolValue : YES;
}

- (void)setCa_interactivePopEnable:(BOOL)gk_interactivePopEnable
{
    self.navigationController.interactivePopGestureRecognizer.enabled = gk_interactivePopEnable;
    objc_setAssociatedObject(self, &GKInteractivePopEnableKey, @(gk_interactivePopEnable), OBJC_ASSOCIATION_RETAIN);
}

#pragma mark property readonly

- (CGFloat)gk_statusBarHeight
{
    CGFloat height = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if(height == 0){
        if([AppDelegate instance].window.gk_safeAreaInsets.bottom > 0){
            height = 44;
        }else{
            height = 20;
        }
    }
    
    return height;
}

- (CGFloat)gk_navigationBarHeight
{
    CGFloat height = self.navigationController.navigationBar.bounds.size.height;
    if(height == 0){
        height = 44;
    }
    
    return height;
}


- (CGFloat)gk_tabBarHeight
{
    if(self.tabBarController){
        return self.tabBarController.tabBar.bounds.size.height;
    }else{
        return 49;
    }
}

- (CGFloat)gk_toolBarHeight
{
    return 44;
}

- (UIViewController*)gk_topestPresentedViewController
{
    if(self.presentedViewController){
        return [self.presentedViewController gk_topestPresentedViewController];
    }else{
        return self;
    }
}

- (UIViewController*)gk_rootPresentingViewController
{
    if(self.presentingViewController){
        return [self.presentingViewController gk_rootPresentingViewController];
    }else{
        return self;
    }
}

#pragma mark navigation

- (__kindof UINavigationController*)gk_createWithNavigationController
{
    return [[GKBaseNavigationController alloc] initWithRootViewController:self];
}

- (void)gk_setNavigationBarItem:(UIBarButtonItem*) item posiiton:(GKNavigationItemPosition) position
{
    item.customView.tintColor = self.navigationController.navigationBar.tintColor;
    item.customView.mj_w += GKNavigationBarMargin * 2;
    switch (position) {
        case GKNavigationItemPositionLeft : {
            self.navigationItem.leftBarButtonItem = item;
        }
            break;
        case GKNavigationItemPositionRight :
            self.navigationItem.rightBarButtonItem = item;
            break;
        default:
            break;
    }
}

- (UIBarButtonItem*)gk_setLeftItemWithTitle:(NSString*) title action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithTitle:title target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gk_setLeftItemWithImage:(UIImage*) image action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithImage:image target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gk_setLeftItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithSystemItem:systemItem target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gk_setLeftItemWithCustomView:(UIView*) customView
{
    UIBarButtonItem *item = [[self class] gk_barItemWithCustomView:customView];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gk_setRightItemWithTitle:(NSString*) title action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithTitle:title target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gk_setRightItemWithImage:(UIImage*) image action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithImage:image target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gk_setRightItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gk_barItemWithSystemItem:systemItem target:self action:action];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gk_setRightItemWithCustomView:(UIView*) customView
{
    UIBarButtonItem *item = [[self class] gk_barItemWithCustomView:customView];
    [self gk_setNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

#pragma mark- Class Method

+ (UIBarButtonItem*)gk_barItemWithImage:(UIImage*) image target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, image.size.width, 44);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem*)gk_barItemWithTitle:(NSString*) title target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont appFontWithSize:14];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [title gk_stringSizeWithFont:btn.titleLabel.font];
    btn.frame = CGRectMake(0, 0, size.width, 44);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem*)gk_barItemWithCustomView:(UIView*) customView
{
    return [[UIBarButtonItem alloc] initWithCustomView:customView];
}

+ (UIBarButtonItem*)gk_barItemWithSystemItem:(UIBarButtonSystemItem) systemItem target:(id) target action:(SEL) action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action];
}


@end
