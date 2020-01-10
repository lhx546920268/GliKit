//
//  GKLabel.m
//  GliKit
//
//  Created by 罗海雄 on 2020/1/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKLabel.h"
#import "UIColor+GKTheme.h"
#import "NSString+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIViewController+GKLoading.h"

@interface GKLabel ()

///是否正在显示items
@property(nonatomic, assign) BOOL menuItemsShowing;

///当前高亮区域
@property(nonatomic, assign) CGRect highlightedRect;

///以前的字体颜色
@property(nonatomic, strong) UIColor *originalTextColor;

///长按手势
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation GKLabel

// MARK: - Insets

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)){
        _contentInsets = contentInsets;
        [self setNeedsDisplay];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    
    if(size.width < 2777777){
        size.width += _contentInsets.left + _contentInsets.right;
    }
    
    if(size.height < 2777777){
        size.height += _contentInsets.top + _contentInsets.bottom;
    }
    
    return size;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect drawRect = UIEdgeInsetsInsetRect(rect, _contentInsets);
    [super drawTextInRect:drawRect];
}

// MARK: - Select

- (void)setSelectable:(BOOL)selectable
{
    if(_selectable != selectable){
        _selectable = selectable;
        if(!self.longPressGesture){
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            longPress.minimumPressDuration = 0.3;
            [self addGestureRecognizer:longPress];
            self.longPressGesture = longPress;
        }

        self.longPressGesture.enabled = _selectable;
        if(_selectable){
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
        }else{
            [NSNotificationCenter.defaultCenter removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
        }
    }
}

- (UIColor *)selectedBackgroundColor
{
    return _selectedBackgroundColor ? _selectedBackgroundColor : UIColor.gkThemeColor;
}

- (UIColor *)selectedTextColor
{
    return _selectedTextColor ? _selectedTextColor : UIColor.gkThemeTintColor;
}

- (NSArray<UIMenuItem *> *)menuItems
{
    return _menuItems ? _menuItems : @[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy:)]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect
{
    if(self.menuItemsShowing){
        //绘制高亮状态
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, self.selectedBackgroundColor.CGColor);
        CGContextAddRect(context, self.highlightedRect);
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
    }
    
    [super drawRect:rect];
}

- (void)setMenuItemsShowing:(BOOL)menuItemsShowing
{
    if(_menuItemsShowing != menuItemsShowing){
        _menuItemsShowing = menuItemsShowing;
        if(_menuItemsShowing){
            self.originalTextColor = self.textColor;
            self.textColor = self.selectedTextColor;
        }else{
            self.textColor = self.originalTextColor;
        }
        [self setNeedsDisplay];
    }
}

// MARK: - 通知

///菜单按钮将要消失
- (void)willHideMenu:(NSNotification*) notification
{
    self.menuItemsShowing = NO;
}

// MARK: - action

///长按
- (void)handleLongPress:(UILongPressGestureRecognizer*) longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan){
        self.menuItemsShowing = YES;
        [self showMenuItems];
    }
}

///复制
- (void)copy:(id)sender
{
    if(![NSString isEmpty:self.text]){
        UIPasteboard.generalPasteboard.string = self.text;
        [self.gkCurrentViewController gkShowSuccessWithText:@"复制成功"];
    }
}

///显示items
- (void)showMenuItems
{
    //计算高亮区域
    CGRect rect = self.bounds;
    CGSize size = [self.text gkStringSizeWithFont:self.font];
    CGRect textRect = CGRectZero;
    textRect.size = CGSizeMake(MIN(size.width, rect.size.width - self.contentInsets.left - self.contentInsets.right),
                               MIN(size.height, rect.size.height - self.contentInsets.top - self.contentInsets.bottom));
    
    
    switch (self.textAlignment) {
        case NSTextAlignmentRight : {
            textRect.origin.x = rect.size.width - textRect.size.width - self.contentInsets.right;
        }
            break;
        case NSTextAlignmentCenter : {
            textRect.origin.x = (rect.size.width - textRect.size.width) / 2.0;
        }
            break;
        default: {
            textRect.origin.x = self.contentInsets.left;
        }
            break;
    }
    
    textRect.origin.y = (rect.size.height - textRect.size.height) / 2.0;
    self.highlightedRect = textRect;
    
    //显示菜单
    [self becomeFirstResponder];
    UIMenuController *controller = [UIMenuController sharedMenuController];
    controller.menuItems = self.menuItems;
    
    if(@available(iOS 13, *)){
        [controller showMenuFromView:self rect:self.highlightedRect];
    }else{
        [controller setTargetRect:self.highlightedRect inView:self];
        [controller setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.canPerformActionHandler){
        return self.canPerformActionHandler(action, sender);
    }
    //只显示自己的
    if(action == @selector(copy:)){
        return YES;
    }

    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return self.menuItemsShowing;
}

@end
