//
//  GKButton.m
//  GliKit
//
//  Created by 罗海雄 on 2019/12/17.
//

#import "GKButton.h"
#import "NSString+GKUtils.h"
#import "NSAttributedString+GKUtils.h"
#import "UIScreen+GKUtils.h"

@interface GKButton ()

///上一次点击的时间，避免重复点击
@property(nonatomic, assign) NSTimeInterval lastTouchTimeInterval;

///点击事件回调
@property(nonatomic, strong) NSMutableSet<GKButtonSingleClickHandler> *singleClickHandlers;

@end

@implementation GKButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initProps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initProps];
    }
    return self;
}

- (void)initProps
{
    self.singleClickTimeInterval = 0.2;
}

// MARK: - Props

- (void)setImagePosition:(GKButtonImagePosition)imagePosition
{
    if(_imagePosition != imagePosition){
        _imagePosition = imagePosition;
        [self setNeedsLayout];
    }
}

- (void)setImagePadding:(CGFloat)imagePadding
{
    if(_imagePadding != imagePadding){
        _imagePadding = imagePadding;
        [self setNeedsLayout];
    }
}

- (void)setImageSize:(CGSize)imageSize
{
    if(!CGSizeEqualToSize(_imageSize, imageSize)){
        _imageSize = imageSize;
        [self setNeedsLayout];
    }
}

// MARK: - Image Position

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    
    if([self shouldChange]){
        CGSize imageSize = self.currentImageSize;
        CGSize titleSize = self.currentTitleSize;
        
        CGFloat width;
        CGFloat height;
        
        switch (self.imagePosition) {
            case GKButtonImagePositionLeft :
            case GKButtonImagePositionRight : {
                width = imageSize.width + self.imagePadding + titleSize.width + self.contentEdgeInsets.left + self.contentEdgeInsets.right;
                height = MAX(imageSize.height, titleSize.height) + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
            }
                break;
            case GKButtonImagePositionTop :
            case GKButtonImagePositionBottom : {
                width = MAX(imageSize.width, titleSize.width) + self.contentEdgeInsets.left + self.contentEdgeInsets.right;
                height = imageSize.height + self.imagePadding + titleSize.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
            }
                break;
        }
        
        size = CGSizeMake(width, height);
    }
    
    return size;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect rect = [super imageRectForContentRect:contentRect];
    if (rect.size.width == 0 || rect.size.height == 0)
        return rect;
    
    if(![self shouldChange]){
        return rect;
    }
    
    CGSize titleSize = self.currentTitleSize;
    CGSize imageSize = self.currentImageSize;
    rect.size.width = imageSize.width;
    rect.size.height = imageSize.height;
    
    CGFloat padding = 0;
    GKButtonImagePosition position = GKButtonImagePositionLeft;
    switch (self.imagePosition) {
        case GKButtonImagePositionLeft : {
            padding = 0;
            position = GKButtonImagePositionRight;
        }
            break;
        case GKButtonImagePositionRight : {
            padding = self.imagePadding;
            position = GKButtonImagePositionLeft;
        }
            break;
        case GKButtonImagePositionTop : {
            padding = 0;
            position = GKButtonImagePositionBottom;
        }
            break;
        case GKButtonImagePositionBottom : {
            padding = self.imagePadding;
            position = GKButtonImagePositionTop;
        }
            break;
    }
    
    rect = [self setupRect:rect contentRect:contentRect anotherSize:titleSize insets:self.imageEdgeInsets padding:padding position:position];
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect rect = [super titleRectForContentRect:contentRect];
    if (rect.size.width == 0 || rect.size.height == 0)
        return rect;
    
    if(![self shouldChange])
        return rect;
    
    rect = [self setupRect:rect contentRect:contentRect anotherSize:self.currentImageSize insets:self.titleEdgeInsets padding:self.imagePadding position:self.imagePosition];
    return rect;
}

///设置rect
- (CGRect)setupRect:(CGRect) rect contentRect:(CGRect) contentRect anotherSize:(CGSize) anotherSize insets:(UIEdgeInsets) insets padding:(CGFloat) padding position:(GKButtonImagePosition) position
{
    contentRect.size.width += self.contentEdgeInsets.left + self.contentEdgeInsets.right;
    contentRect.size.height += self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
    UIControlContentHorizontalAlignment horizontal = self.currentContentHorizontalAlignment;
    UIControlContentVerticalAlignment vertical = self.contentVerticalAlignment;
    
    switch (position) {
        case GKButtonImagePositionLeft :
        case GKButtonImagePositionRight : {
            switch (vertical) {
                case UIControlContentVerticalAlignmentTop : {
                    rect.origin.y = self.contentEdgeInsets.top + insets.top;
                }
                    break;
                case UIControlContentVerticalAlignmentCenter : {
                    rect.origin.y = contentRect.origin.y + (contentRect.size.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom - rect.size.height) / 2.0 + self.contentEdgeInsets.top + insets.top - insets.bottom;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom : {
                    rect.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case GKButtonImagePositionTop :{
            switch (vertical) {
                case UIControlContentVerticalAlignmentTop : {
                    rect.origin.y = self.contentEdgeInsets.top + anotherSize.height + insets.top + padding;
                }
                    break;
                case UIControlContentVerticalAlignmentCenter : {
                    rect.origin.y = contentRect.origin.y + (contentRect.size.height - (anotherSize.height + padding + rect.size.height)) / 2.0 + insets.top - insets.bottom + anotherSize.height + padding;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom : {
                    rect.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case GKButtonImagePositionBottom : {
            switch (vertical) {
                case UIControlContentVerticalAlignmentTop : {
                    rect.origin.y = self.contentEdgeInsets.top + insets.top;
                }
                    break;
                case UIControlContentVerticalAlignmentCenter : {
                    rect.origin.y = contentRect.origin.y + (contentRect.size.height - (anotherSize.height + padding + rect.size.height)) / 2.0 + insets.top - insets.bottom;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom : {
                    rect.origin.y = contentRect.size.height - rect.size.height - self.contentEdgeInsets.bottom - insets.bottom;
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
    
    switch (position) {
        case GKButtonImagePositionLeft : {
            
            switch (horizontal) {
                case UIControlContentHorizontalAlignmentLeft : {
                    rect.origin.x = self.contentEdgeInsets.left + anotherSize.width + insets.left + padding;
                }
                    break;
                case UIControlContentHorizontalAlignmentCenter : {
                    rect.origin.x = (contentRect.size.width - (anotherSize.width + padding + rect.size.width)) / 2.0 + insets.left - insets.right + anotherSize.width + padding;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight : {
                    rect.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case GKButtonImagePositionRight : {
            switch (horizontal) {
                case UIControlContentHorizontalAlignmentLeft : {
                    rect.origin.x = self.contentEdgeInsets.left + insets.left;
                }
                    break;
                case UIControlContentHorizontalAlignmentCenter : {
                    rect.origin.x = (contentRect.size.width - (anotherSize.width + padding + rect.size.width)) / 2.0 + insets.left - insets.right;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight : {
                    rect.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case GKButtonImagePositionTop :
        case GKButtonImagePositionBottom : {
            switch (horizontal) {
                case UIControlContentHorizontalAlignmentLeft: {
                    rect.origin.x = self.contentEdgeInsets.left + insets.left;
                }
                    break;
                case UIControlContentHorizontalAlignmentCenter : {
                    rect.origin.x = (contentRect.size.width - rect.size.width) / 2.0 + insets.left - insets.right;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight : {
                    rect.origin.x = contentRect.size.width - rect.size.width - self.contentEdgeInsets.right - insets.right;
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
    
    return rect;
}

///是否需要
- (BOOL)shouldChange
{
    if(self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill || self.contentVerticalAlignment == UIControlContentVerticalAlignmentFill){
        return NO;
    }
    
    if(self.imagePosition == GKButtonImagePositionLeft && self.imagePadding == 0 && CGSizeEqualToSize(self.imageSize, CGSizeZero)){
        return NO;
    }
    
    return YES;
}

///获取图标大小
- (CGSize)currentImageSize
{
    UIImage *image = self.currentImage;
    if(image){
        return CGSizeEqualToSize(self.imageSize, CGSizeZero) ? image.size : self.imageSize;
    }else{
        return CGSizeZero;
    }
}

///获取当前标题大小
- (CGSize)currentTitleSize
{
    NSAttributedString *attributedTitle = self.currentAttributedTitle;
    if(attributedTitle){
        return [attributedTitle gkBoundsWithConstraintWidth:CGFLOAT_MAX];
    }
    
    NSString *title = self.currentTitle;
    if(title){
        return [title gkStringSizeWithFont:self.titleLabel.font];
    }
    
    return CGSizeZero;
}

///获取当前水平对齐方式
- (UIControlContentHorizontalAlignment)currentContentHorizontalAlignment
{
    UIControlContentHorizontalAlignment horizontal = self.contentHorizontalAlignment;
    if(horizontal == UIControlContentHorizontalAlignmentLeading){
        horizontal = UIControlContentHorizontalAlignmentLeft;
    }else if (horizontal == UIControlContentHorizontalAlignmentTrailing){
        horizontal = UIControlContentHorizontalAlignmentRight;
    }
    
    return horizontal;
}

// MARK: - Single Click

- (NSMutableSet<GKButtonSingleClickHandler> *)singleClickHandlers
{
    if (!_singleClickHandlers) {
        _singleClickHandlers = [NSMutableSet set];
    }
    return _singleClickHandlers;
}

- (void)addSingleClickHandler:(GKButtonSingleClickHandler)handler
{
    if ([self actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].count == 0) {
        [self addTarget:self action:@selector(internalHandleTap) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.singleClickHandlers addObject:handler];
}

- (void)removeSingleClickHandler:(GKButtonSingleClickHandler)handler
{
    [_singleClickHandlers removeObject:handler];
}

- (void)internalHandleTap
{
    NSTimeInterval timeInterval = NSDate.date.timeIntervalSince1970;
    //避免系统时间改了 无法点击
    if (timeInterval < self.lastTouchTimeInterval
        || timeInterval - self.lastTouchTimeInterval >= self.singleClickTimeInterval) {
        self.lastTouchTimeInterval = timeInterval;
        for (GKButtonSingleClickHandler handler in _singleClickHandlers) {
            handler();
        }
    }
}

@end
