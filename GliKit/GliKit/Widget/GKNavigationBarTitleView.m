//
//  GKNavigationBarTitleView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKNavigationBarTitleView.h"
#import "UIView+GKUtils.h"
#import "UIScreen+GKUtils.h"
#import "UIApplication+GKTheme.h"

@implementation GKNavigationBarTitleView

@synthesize contentSize = _contentSize;

- (instancetype)initWithNavigationItem:(UINavigationItem *)item
{
    self = [super initWithFrame:CGRectMake(0, 0, UIScreen.gkWidth, 30)];
    if(self){
        
        _navigationItem = item;
        self.clipsToBounds = NO;
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
    }
    
    return self;
}

- (CGFloat)marginForItem
{
    return UIApplication.gkNavigationBarMarginForItem;
}

- (CGFloat)marginForScreen
{
    return 0;
}

- (CGSize)intrinsicContentSize
{
    CGSize size = self.contentSize;
    if(size.width == 0 || size.height == 0){
        return UILayoutFittingExpandedSize;
    }
    return size;
}

- (void)setContentSize:(CGSize)contentSize
{
    if(!CGSizeEqualToSize(_contentSize, contentSize)){
        _contentSize = contentSize;
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)contentSize
{
    if(CGSizeEqualToSize(_contentSize, CGSizeZero)){
        CGFloat width = UIScreen.gkWidth;
        UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
        if(item){
            width -= item.customView.gkWidth + self.marginForItem;
        }
        
        item = self.navigationItem.rightBarButtonItem;
        if(item){
            width -= item.customView.gkWidth + self.marginForItem;
        }
        
        return CGSizeMake(width, self.gkHeight);
    }
    
    return _contentSize;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    CGSize size = self.contentSize;
    self.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.gkWidth;
    CGRect frame = CGRectMake(0, 0, 0, self.gkHeight);
    
    CGFloat margin = self.marginForScreen;
    
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    if(item){
        frame.origin.x = -self.marginForItem;
        width += self.marginForItem;
    }else{
        frame.origin.x = UIApplication.gkNavigationBarMargin - margin;
        width -= UIApplication.gkNavigationBarMargin - margin;
    }
    
    item = self.navigationItem.rightBarButtonItem;
    if(item){
        width += self.marginForItem;
    }else{
        width -= UIApplication.gkNavigationBarMargin - margin;
    }
    
    frame.size.width = width;
    
    self.contentView.frame = frame;
}

@end
