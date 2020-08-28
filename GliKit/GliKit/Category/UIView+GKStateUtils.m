//
//  UIView+GKStateUtils.m
//  AFNetworking
//
//  Created by 罗海雄 on 2019/12/11.
//

#import "UIView+GKStateUtils.h"
#import <objc/runtime.h>
#import "NSObject+GKUtils.h"

static char GKBackgroundColorKey;
static char GKTintColorKey;

@implementation UIView (GKStateUtils)

///当前状态
- (UIControlState)gkState
{
    return UIControlStateNormal;
}

///状态改变
- (void)gkStateDidChange
{
    [self gkAdjustsBackgroundColor];
    [self gkAdjustsTintColor];
}

// MARK: - 背景颜色

///状态背景
- (NSMutableDictionary<NSNumber*,UIColor*>*)gkBackgroundColorsForState
{
    return objc_getAssociatedObject(self, &GKBackgroundColorKey);
}

- (void)gkSetBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    NSMutableDictionary *dic = self.gkBackgroundColorsForState;
    if(!backgroundColor && !dic)
        return;
    
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &GKBackgroundColorKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if(backgroundColor){
        [dic setObject:backgroundColor forKey:@(state)];
    }else{
        [dic removeObjectForKey:@(state)];
    }
    
    if(self.gkState == state){
        [self gkAdjustsBackgroundColor];
    }
}

- (UIColor*)gkCurrentBackgroundColor
{
    UIColor *color = [self.gkBackgroundColorsForState objectForKey:@(self.gkState)];
 
    if(!color){
        color = self.backgroundColor;
    }
    
    return color;
}

///调整背景颜色
- (void)gkAdjustsBackgroundColor
{
    NSMutableDictionary *dic = self.gkBackgroundColorsForState;
    if(dic.count > 0){
        self.backgroundColor = self.gkCurrentBackgroundColor;
    }
}

// MARK: - TintColor

- (void)gkSetTintColor:(UIColor *)tintColor forState:(UIControlState)state
{
    NSMutableDictionary *dic = self.gkTintColorsForState;
    if(!tintColor && !dic)
           return;
       
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &GKTintColorKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
       
    if(tintColor){
        [dic setObject:tintColor forKey:@(state)];
    }else{
        [dic removeObjectForKey:@(state)];
    }
    
    if(self.gkState == state){
        [self gkAdjustsTintColor];
    }
}

- (NSMutableDictionary<NSNumber*,UIColor*>*)gkTintColorsForState
{
    return objc_getAssociatedObject(self, &GKTintColorKey);
}

- (UIColor*)gkCurrentTintColor
{
    UIColor *color = [self.gkTintColorsForState objectForKey:@(self.gkState)];

    if(!color){
        color = self.tintColor;
    }
    
    return color;
}

///调整背景颜色
- (void)gkAdjustsTintColor
{
    NSMutableDictionary *dic = self.gkTintColorsForState;
    if(dic.count > 0){
        self.tintColor = self.gkCurrentTintColor;
    }
}

@end

@implementation UIButton (GKStateUtils)

+ (void)load
{
    SEL selectors[] = {
        
        @selector(setEnabled:),
        @selector(setHighlighted:),
        @selector(setSelected:)
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(NSInteger i = 0;i < count;i ++){
        [self gkExchangeImplementations:selectors[i] prefix:@"gk_"];
    }
}

// MARK: - 状态

- (UIControlState)gkState
{
    return self.state;
}

- (void)gk_setHighlighted:(BOOL)highlighted
{
    [self gk_setHighlighted:highlighted];
    [self gkStateDidChange];
}

- (void)gk_setSelected:(BOOL)selected
{
    [self gk_setSelected:selected];
    [self gkStateDidChange];
}

- (void)gk_setEnabled:(BOOL)enabled
{
    [self gk_setEnabled:enabled];
    [self gkStateDidChange];
}

@end

@implementation UIImageView (GKStateUtils)

+ (void)load
{
    [self gkExchangeImplementations:@selector(setHighlighted:) prefix:@"gk_"];
}

- (void)gkSetBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [super gkSetBackgroundColor:backgroundColor forState:state];
    
    if((self.highlighted && state == UIControlStateHighlighted) || (!self.highlighted && state == UIControlStateNormal)){
        self.backgroundColor = self.gkCurrentBackgroundColor;
    }
}

// MARK: - 状态

- (UIControlState)gkState
{
    return self.highlighted ? UIControlStateHighlighted : UIControlStateNormal;
}

- (void)gk_setHighlighted:(BOOL)highlighted
{
    [self gk_setHighlighted:highlighted];
    [self gkStateDidChange];
}

@end

@implementation UILabel (GKStateUtils)

+ (void)load
{
    SEL selectors[] = {
        
        @selector(setEnabled:),
        @selector(setHighlighted:),
    };
    
    int count = sizeof(selectors) / sizeof(SEL);
    for(NSInteger i = 0;i < count;i ++){
        [self gkExchangeImplementations:selectors[i] prefix:@"gk_"];
    }
}

// MARK: - 状态

- (UIControlState)gkState
{
    if(!self.enabled){
        return UIControlStateDisabled;
    }
    
    if(self.highlighted){
        return UIControlStateHighlighted;
    }
    
    return UIControlStateNormal;
}

- (void)gk_setHighlighted:(BOOL)highlighted
{
    [self gk_setHighlighted:highlighted];
    [self gkStateDidChange];
}

- (void)gk_setEnabled:(BOOL)enabled
{
    [self gk_setEnabled:enabled];
    [self gkStateDidChange];
}

@end
