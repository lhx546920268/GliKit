//
//  UIButton+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIButton+GKUtils.h"
#import "NSString+GKUtils.h"
#import "NSObject+GKUtils.h"
#import <objc/runtime.h>

///保存背景颜色的key
static char GKButtonBackgroundColorKey;
static char GKContentEdgeInsetsKey;
static char GKButtonTintColorKey;

@implementation UIButton (GKUtils)

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

- (void)setGkContentEdgeInsets:(UIEdgeInsets)gkContentEdgeInsets
{
    objc_setAssociatedObject(self, &GKContentEdgeInsetsKey, [NSValue valueWithUIEdgeInsets:gkContentEdgeInsets], OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)gkContentEdgeInsets
{
    return [objc_getAssociatedObject(self, &GKContentEdgeInsetsKey) UIEdgeInsetsValue];
}

- (void)gkSetImagePosition:(GKButtonImagePosition) position margin:(CGFloat) margin
{
    if(self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill || self.contentVerticalAlignment == UIControlContentVerticalAlignmentFill){
        return;
    }
    
    [self layoutIfNeeded];
    
    UIImage *image = self.currentImage;
    NSString *title = self.currentTitle;
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGFloat titleWidth = size.width;
    CGFloat titleHeight = size.height;
    
    UIEdgeInsets titleInsets = UIEdgeInsetsZero;
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    if([NSString isEmpty:title] || !image){
        self.titleEdgeInsets = titleInsets;
        self.imageEdgeInsets = imageInsets;
        self.contentEdgeInsets = contentInsets;
        return;
    }
    
    switch (position) {
        case GKButtonImagePositionLeft : {
            
            UIControlContentHorizontalAlignment contentHorizontalAlignment = self.contentHorizontalAlignment;
            
            if(@available(iOS 11.0, *)){
                if(contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeading){
                    contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                }else if (contentHorizontalAlignment == UIControlContentHorizontalAlignmentTrailing){
                    contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                }
            }
            
            switch (contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter : {
                    titleInsets.left = margin / 2;
                    titleInsets.right = - margin / 2;
                    
                    imageInsets.left = - margin / 2;
                    imageInsets.right = margin / 2;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft : {
                    titleInsets.left = margin;
                    titleInsets.right = - margin;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight : {
                    imageInsets.left = - margin;
                    imageInsets.right = margin;
                }
                    break;
                default:
                    break;
            }
            
            //图标和文字 + 间隔已经超过 父视图范围了，点击事件将不触发，设置contentInset 可扩大UIButton的大小
            if(imageWidth + titleWidth + margin > self.bounds.size.width){
                switch (contentHorizontalAlignment) {
                    case UIControlContentHorizontalAlignmentCenter : {
                        contentInsets.left = margin / 2;
                        contentInsets.right = margin / 2;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentLeft : {
                        contentInsets.right = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentRight : {
                        contentInsets.left = margin;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case GKButtonImagePositionTop : {
            
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentCenter : {
                    titleInsets.top = (imageHeight + margin) / 2;
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.bottom = - (imageHeight + margin) / 2;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.top = - (titleHeight + margin) / 2;
                    imageInsets.left = titleWidth / 2;
                    imageInsets.bottom = (titleHeight + margin) / 2;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                case UIControlContentVerticalAlignmentTop : {
                    titleInsets.top = imageHeight + margin;
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.bottom = - imageHeight - margin;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.left = titleWidth / 2;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom : {
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.top = - titleHeight - margin;
                    imageInsets.left = titleWidth / 2;
                    imageInsets.bottom = titleHeight + margin;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                default:
                    break;
            }
            
            //图标和文字 + 间隔已经超过 父视图范围了，点击事件将不触发，设置contentInset 可扩大UIButton的大小
            if(imageHeight + titleHeight + margin > self.bounds.size.height){
                switch (self.contentVerticalAlignment) {
                    case UIControlContentVerticalAlignmentCenter : {
                        int value = (imageHeight + titleHeight + margin - self.bounds.size.height) / 2.0;
                        contentInsets.top = value;
                        contentInsets.bottom = value;
                    }
                        break;
                    case UIControlContentVerticalAlignmentTop : {
                        contentInsets.bottom = imageHeight + titleHeight + margin - self.bounds.size.height;
                    }
                        break;
                    case UIControlContentVerticalAlignmentBottom : {
                        contentInsets.top = imageHeight + titleHeight + margin - self.bounds.size.height;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case GKButtonImagePositionRight : {
            
            UIControlContentHorizontalAlignment contentHorizontalAlignment = self.contentHorizontalAlignment;
            
            if(@available(iOS 11.0, *)){
                if(contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeading){
                    contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                }else if (contentHorizontalAlignment == UIControlContentHorizontalAlignmentTrailing){
                    contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                }
            }
            
            switch (contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter : {
                    titleInsets.left = - imageWidth - margin / 2;
                    titleInsets.right = imageWidth + margin / 2;
                    
                    imageInsets.left = titleWidth + margin / 2;
                    imageInsets.right = - titleWidth - margin / 2;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft : {
                    titleInsets.left = - imageWidth;
                    titleInsets.right = imageWidth;
                    
                    imageInsets.left = titleWidth + margin;
                    imageInsets.right = - titleWidth - margin;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight : {
                    titleInsets.left = - imageWidth - margin;
                    titleInsets.right = imageWidth + margin;
                    
                    imageInsets.left = titleWidth;
                    imageInsets.right = - titleWidth;
                }
                    break;
                default:
                    break;
            }
            
            //图标和文字 + 间隔已经超过 父视图范围了，点击事件将不触发，设置contentInset 可扩大UIButton的大小
            if(imageWidth + titleWidth + margin > self.bounds.size.width){
                switch (contentHorizontalAlignment) {
                    case UIControlContentHorizontalAlignmentCenter : {
                        contentInsets.left = margin / 2;
                        contentInsets.right = margin / 2;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentLeft : {
                        contentInsets.right = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentRight : {
                        contentInsets.left = margin;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case GKButtonImagePositionBottom : {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentCenter : {
                    titleInsets.top = - (imageHeight + margin) / 2;
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.bottom = (imageHeight + margin) / 2;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.top = (titleHeight + margin) / 2;
                    imageInsets.left = titleWidth / 2;
                    imageInsets.bottom = - (titleHeight + margin) / 2;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                case UIControlContentVerticalAlignmentTop : {
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.top = titleHeight + margin;
                    imageInsets.left = titleWidth / 2;
                    imageInsets.bottom = - titleHeight - margin;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom : {
                    titleInsets.top =  - imageHeight - margin;
                    titleInsets.left = - imageWidth / 2;
                    titleInsets.bottom = imageHeight + margin;
                    titleInsets.right = imageWidth / 2;
                    
                    imageInsets.left = titleWidth / 2;
                    imageInsets.right = - titleWidth / 2;
                }
                    break;
                default:
                    break;
            }
            
            //图标和文字 + 间隔已经超过 父视图范围了，点击事件将不触发，设置contentInset 可扩大UIButton的大小
            if(imageHeight + titleHeight + margin > self.bounds.size.height){
                switch (self.contentVerticalAlignment) {
                    case UIControlContentVerticalAlignmentCenter : {
                        int value = (imageHeight + titleHeight + margin - self.bounds.size.height) / 2.0;
                        contentInsets.top = value;
                        contentInsets.bottom = value;
                    }
                        break;
                    case UIControlContentVerticalAlignmentTop : {
                        contentInsets.bottom = imageHeight + titleHeight + margin - self.bounds.size.height;
                    }
                        break;
                    case UIControlContentVerticalAlignmentBottom : {
                        contentInsets.top = imageHeight + titleHeight + margin - self.bounds.size.height;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }
    
    self.titleEdgeInsets = titleInsets;
    self.imageEdgeInsets = imageInsets;
    self.contentEdgeInsets = contentInsets;
}

// MARK: - 状态

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
    return objc_getAssociatedObject(self, &GKButtonBackgroundColorKey);
}

- (void)gkSetBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    NSMutableDictionary *dic = [self gkBackgroundColorsForState];
    if(!backgroundColor && !dic)
        return;
    
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &GKButtonBackgroundColorKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if(backgroundColor){
        [dic setObject:backgroundColor forKey:@(state)];
    }else{
        [dic removeObjectForKey:@(state)];
    }
    
    if(self.state == state){
        self.backgroundColor = backgroundColor;
    }
}

///获取当前颜色
- (UIColor*)gkCurrentBackgroundColorFromDictionary:(NSDictionary*) dic
{
    UIColor *color = nil;
    if(!self.enabled){
        
        color = [dic objectForKey:@(UIControlStateDisabled)];
    }else if(self.highlighted){
        
        color = [dic objectForKey:@(UIControlStateHighlighted)];
        if(!color){
            color = [dic objectForKey:@(self.selected ? UIControlStateSelected : UIControlStateNormal)];
        }
    }else if (self.selected){
        color = [dic objectForKey:@(UIControlStateSelected)];
    }
    
    if(!color){
        color = [dic objectForKey:@(UIControlStateNormal)];
    }
    
    if(!color){
        color = self.backgroundColor;
    }
    
    return color;
}

///调整背景颜色
- (void)gkAdjustsBackgroundColor
{
    NSMutableDictionary *dic = [self gkBackgroundColorsForState];
    if(dic.count > 0){
        self.backgroundColor = [self gkCurrentBackgroundColorFromDictionary:dic];
    }
}

// MARK: - TintColor

- (void)gkSetTintColor:(UIColor *)tintColor forState:(UIControlState)state
{
    NSMutableDictionary *dic = [self gkTintColorsForState];
    if(!tintColor && !dic)
           return;
       
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &GKButtonTintColorKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
       
    if(tintColor){
        [dic setObject:tintColor forKey:@(state)];
    }else{
        [dic removeObjectForKey:@(state)];
    }
       
    if(self.state == state){
        self.tintColor = tintColor;
    }
}

///状态背景
- (NSMutableDictionary<NSNumber*,UIColor*>*)gkTintColorsForState
{
    return objc_getAssociatedObject(self, &GKButtonTintColorKey);
}

///获取当前颜色
- (UIColor*)gkCurrentTintColorFromDictionary:(NSDictionary*) dic
{
    UIColor *color = nil;
    if(!self.enabled){
        
        color = [dic objectForKey:@(UIControlStateDisabled)];
    }else if(self.highlighted){
        
        color = [dic objectForKey:@(UIControlStateHighlighted)];
        if(!color){
            color = [dic objectForKey:@(self.selected ? UIControlStateSelected : UIControlStateNormal)];
        }
    }else if (self.selected){
        color = [dic objectForKey:@(UIControlStateSelected)];
    }
    
    if(!color){
        color = [dic objectForKey:@(UIControlStateNormal)];
    }
    
    if(!color){
        color = self.tintColor;
    }
    
    return color;
}

///调整背景颜色
- (void)gkAdjustsTintColor
{
    NSMutableDictionary *dic = [self gkTintColorsForState];
    if(dic.count > 0){
        self.tintColor = [self gkCurrentTintColorFromDictionary:dic];
    }
}

@end
