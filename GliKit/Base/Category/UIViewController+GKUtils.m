//
//  UIViewController+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKUtils.h"
#import <objc/runtime.h>
#import "GKBaseNavigationController.h"
#import "UINavigationBar+GKUtils.h"
#import "UIView+GKUtils.h"
#import "UIApplication+GKTheme.h"
#import "NSString+GKUtils.h"

///返回按钮
static char GKBackItemViewKey;

///是否可以活动返回
static char GKInteractivePopEnableKey;

///返回按钮tag
static const NSInteger GKBackItemTag = 10329;

@implementation UIViewController (Utils)

- (void)setGkHideNavigationBarShadowImage:(BOOL)gkHideNavigationBarShadowImage
{
    UIImageView *shadowImageView = [self gkFindShadowImageView:self.navigationController.navigationBar];
    shadowImageView.hidden = gkHideNavigationBarShadowImage;
}

- (UIImageView*)gkFindShadowImageView:(UIView*)view
{
    if([view isKindOfClass:[UIImageView class]] && view.bounds.size.height <= 1.0){
        return (UIImageView*) view;
    }
    
    for(UIView *subView in view.subviews){
        UIImageView *imageView = [self gkFindShadowImageView:subView];
        if(imageView){
            return imageView;
        }
    }
    
    return nil;
}

- (BOOL)gkInteractivePopEnable
{
    NSNumber *number = objc_getAssociatedObject(self, &GKInteractivePopEnableKey);
    return number ? number.boolValue : YES;
}

- (void)setCa_interactivePopEnable:(BOOL)gk_interactivePopEnable
{
    self.navigationController.interactivePopGestureRecognizer.enabled = gk_interactivePopEnable;
    objc_setAssociatedObject(self, &GKInteractivePopEnableKey, @(gk_interactivePopEnable), OBJC_ASSOCIATION_RETAIN);
}

//MARK: 返回

- (void)setGkShowBackItem:(BOOL)gkShowBackItem
{
    if(gkShowBackItem){
        UIImage *image = [UIImage imageNamed:@"nav_btn_back_white"];
        //Template
        if(image.renderingMode != UIImageRenderingModeAlwaysTemplate){
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        UIBarButtonItem *item = [[self class] gkBarItemWithImage:image target:self action:@selector(gkBack)];
        item.customView.tag = GKBackItemTag;
        objc_setAssociatedObject(self, &GKBackItemViewKey, item.customView, OBJC_ASSOCIATION_RETAIN);
        [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.hidesBackButton = YES;
        objc_setAssociatedObject(self, &GKBackItemViewKey, nil, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIView *)gkBackItem
{
    return objc_getAssociatedObject(self, &GKBackItemViewKey);
}

- (BOOL)gkShowBackItem
{
    return self.navigationItem.leftBarButtonItem.customView.tag == GKBackItemTag;
}

- (void)gkBack
{
    [self gkBackAnimated:YES];
}

- (void)gkBackAnimated:(BOOL) flag
{
    [self gkBackAnimated:flag completion:nil];
}

- (void)gkBackAnimated:(BOOL) flag completion: (void (^)(void))completion
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

//MARK: property readonly

- (CGFloat)gkStatusBarHeight
{
    CGFloat height = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if(height == 0){
        if(UIApplication.sharedApplication.delegate.window.gkSafeAreaInsets.bottom > 0){
            height = 44;
        }else{
            height = 20;
        }
    }
    
    return height;
}

- (CGFloat)gkNavigationBarHeight
{
    CGFloat height = self.navigationController.navigationBar.bounds.size.height;
    if(height == 0){
        height = 44;
    }
    
    return height;
}


- (CGFloat)gkTabBarHeight
{
    if(self.tabBarController){
        return self.tabBarController.tabBar.bounds.size.height;
    }else{
        return 49;
    }
}

- (CGFloat)gkToolBarHeight
{
    return 44;
}

- (__kindof UIViewController *)gkTopestPresentedViewController
{
    if(self.presentedViewController){
        return [self.presentedViewController gkTopestPresentedViewController];
    }else{
        return self;
    }
}

- (__kindof UIViewController*)gkRootPresentingViewController
{
    if(self.presentingViewController){
        return [self.presentingViewController gkRootPresentingViewController];
    }else{
        return self;
    }
}

- (__kindof UINavigationController*)gkCreateWithNavigationController
{
    return [[GKBaseNavigationController alloc] initWithRootViewController:self];
}

//MARK: 导航栏按钮

- (void)gkSetNavigationBarItem:(UIBarButtonItem*) item posiiton:(GKNavigationItemPosition) position
{
    item.customView.tintColor = self.navigationController.navigationBar.tintColor;
    item.customView.gkWidth += UIApplication.gkNavigationBarMargin * 2;
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

- (UIBarButtonItem*)gkSetLeftItemWithTitle:(NSString*) title action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithTitle:title target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gkSetLeftItemWithImage:(UIImage*) image action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithImage:image target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gkSetLeftItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithSystemItem:systemItem target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gkSetLeftItemWithCustomView:(UIView*) customView
{
    UIBarButtonItem *item = [[self class] gkBarItemWithCustomView:customView];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionLeft];
    
    return item;
}

- (UIBarButtonItem*)gkSetRightItemWithTitle:(NSString*) title action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithTitle:title target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gkSetRightItemWithImage:(UIImage*) image action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithImage:image target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gkSetRightItemWithSystemItem:(UIBarButtonSystemItem) systemItem action:(SEL) action
{
    UIBarButtonItem *item = [[self class] gkBarItemWithSystemItem:systemItem target:self action:action];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

- (UIBarButtonItem*)gkSetRightItemWithCustomView:(UIView*) customView
{
    UIBarButtonItem *item = [[self class] gkBarItemWithCustomView:customView];
    [self gkSetNavigationBarItem:item posiiton:GKNavigationItemPositionRight];
    
    return item;
}

//MARK: Class Method

+ (UIBarButtonItem*)gkBarItemWithImage:(UIImage*) image target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, image.size.width, 44);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem*)gkBarItemWithTitle:(NSString*) title target:(id) target action:(SEL) action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [title gkStringSizeWithFont:btn.titleLabel.font];
    btn.frame = CGRectMake(0, 0, size.width, 44);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem*)gkBarItemWithCustomView:(UIView*) customView
{
    return [[UIBarButtonItem alloc] initWithCustomView:customView];
}

+ (UIBarButtonItem*)gkBarItemWithSystemItem:(UIBarButtonSystemItem) systemItem target:(id) target action:(SEL) action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action];
}


@end
