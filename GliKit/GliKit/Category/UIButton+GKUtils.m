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

static char GKContentEdgeInsetsKey;

@implementation UIButton (GKUtils)


- (void)setGkContentEdgeInsets:(UIEdgeInsets)gkContentEdgeInsets
{
    objc_setAssociatedObject(self, &GKContentEdgeInsetsKey, @(gkContentEdgeInsets), OBJC_ASSOCIATION_RETAIN);
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
            
            switch (contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter : {
                    titleInsets.left = margin / 2;
                    titleInsets.right = - margin / 2;
                    
                    imageInsets.left = - margin / 2;
                    imageInsets.right = margin / 2;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft :
                case UIControlContentHorizontalAlignmentLeading : {
                    titleInsets.left = margin;
                    titleInsets.right = - margin;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight :
                case UIControlContentHorizontalAlignmentTrailing : {
                    imageInsets.left = - margin;
                    imageInsets.right = margin;
                }
                    break;
                case UIControlContentHorizontalAlignmentFill :
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
                    case UIControlContentHorizontalAlignmentLeft :
                    case UIControlContentHorizontalAlignmentLeading : {
                        contentInsets.right = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentRight :
                    case UIControlContentHorizontalAlignmentTrailing : {
                        contentInsets.left = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentFill :
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
                case UIControlContentVerticalAlignmentFill :
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
                    case UIControlContentVerticalAlignmentFill :
                        break;
                }
            }
        }
            break;
        case GKButtonImagePositionRight : {
            
            UIControlContentHorizontalAlignment contentHorizontalAlignment = self.contentHorizontalAlignment;
            
            switch (contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter : {
                    titleInsets.left = - imageWidth - margin / 2;
                    titleInsets.right = imageWidth + margin / 2;
                    
                    imageInsets.left = titleWidth + margin / 2;
                    imageInsets.right = - titleWidth - margin / 2;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft :
                case UIControlContentHorizontalAlignmentLeading : {
                    titleInsets.left = - imageWidth;
                    titleInsets.right = imageWidth;
                    
                    imageInsets.left = titleWidth + margin;
                    imageInsets.right = - titleWidth - margin;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight :
                case UIControlContentHorizontalAlignmentTrailing : {
                    titleInsets.left = - imageWidth - margin;
                    titleInsets.right = imageWidth + margin;
                    
                    imageInsets.left = titleWidth;
                    imageInsets.right = - titleWidth;
                }
                    break;
                case UIControlContentHorizontalAlignmentFill :
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
                    case UIControlContentHorizontalAlignmentLeft :
                    case UIControlContentHorizontalAlignmentLeading : {
                        contentInsets.right = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentRight :
                    case UIControlContentHorizontalAlignmentTrailing : {
                        contentInsets.left = margin;
                    }
                        break;
                    case UIControlContentHorizontalAlignmentFill :
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
                case UIControlContentVerticalAlignmentFill :
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
                    case UIControlContentVerticalAlignmentFill :
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

@end
