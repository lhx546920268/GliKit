//
//  UITextField+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UITextField+GKUtils.h"
#import <objc/runtime.h>

static char GKForbiddenActionsKey;
static char GKMaxLengthKey;
static char GKTextTypeKey;
static char GKTextDidChangeKey;
static char GKExtraStringKey;


@implementation UITextField (GKUtils)

#pragma mark- 内嵌视图

- (void)gk_setLeftViewWithImageName:(NSString*) imageName padding:(CGFloat)padding
{
    self.leftViewMode = UITextFieldViewModeAlways;
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.mj_h - image.size.height) / 2.0, image.size.width + padding, image.size.height)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    self.leftView = imageView;
}

- (void)gk_setRightViewWithImageName:(NSString*) imageName padding:(CGFloat)padding
{
    self.rightViewMode = UITextFieldViewModeAlways;
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.mj_h - image.size.height) / 2.0, image.size.width + padding, image.size.height)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    self.rightView = imageView;
}

- (UIView*)gk_setDefaultSeparator
{
    return [self gk_setSeparatorWithColor:UIColor.appSeparatorColor height:GKSeparatorHeight];
}

- (UIView*)gk_setSeparatorWithColor:(UIColor *)color height:(CGFloat)height
{
    UIView *separator = self.gk_separator;
    separator.backgroundColor = color;
    separator.gk_heightLayoutConstraint.constant = height;
    
    return separator;
}

- (UIView*)gk_separator
{
    UIView *separator = objc_getAssociatedObject(self, _cmd);
    if(!separator){
        separator = [UIView new];
        [self addSubview:separator];
        
        [separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.equalTo(GKSeparatorHeight);
        }];
        
        objc_setAssociatedObject(self, _cmd, separator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return separator;
}

- (void)gk_addDefaultInputAccessoryViewWithTarget:(id) target action:(SEL) action
{
    [self gk_addDefaultInputAccessoryViewWithTitle:nil target:target action:action];
}

- (void)gk_addDefaultInputAccessoryView
{
    [self gk_addDefaultInputAccessoryViewWithTarget:nil action:nil];
}

- (void)gk_addDefaultInputAccessoryViewWithTitle:(NSString *)title
{
    [self gk_addDefaultInputAccessoryViewWithTitle:title target:nil action:nil];
}

- (void)gk_addDefaultInputAccessoryViewWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    if([NSString isEmpty:title]){
        title = @"ok".zegoLocalizedString;
    }
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 35)];
    toolbar.backgroundColor = [UIColor gk_colorFromHex:@"dbdbdb"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.appThemeColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont appFontWithSize:16];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    if(target && action){
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn addTarget:self action:@selector(gk_handleConfirm) forControlEvents:UIControlEventTouchUpInside];
    }
    [toolbar addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(toolbar);
    }];
    
    self.inputAccessoryView = toolbar;
}

- (void)gk_handleConfirm
{
    [self resignFirstResponder];
}

#pragma mark 文本限制

- (BOOL)gk_shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //删除
    NSString *extraString = self.gk_extraString;
    if(string.length == 0 && range.location >= self.text.length - extraString.length){
        self.gk_selectedRange = NSMakeRange(self.text.length - extraString.length, 0);
        return NO;
    }
    return YES;
}

- (void)setCa_maxLength:(NSUInteger) length
{
    objc_setAssociatedObject(self, &GKMaxLengthKey, @(length), OBJC_ASSOCIATION_RETAIN);
    [self shouldObserveEditingChange];
}

- (NSUInteger)gk_maxLength
{
    NSNumber *number = objc_getAssociatedObject(self, &GKMaxLengthKey);
    return number ? [number unsignedIntegerValue] : NSUIntegerMax;
}

- (void)setCa_textType:(GKTextType) textType
{
    objc_setAssociatedObject(self, &GKTextTypeKey, @(textType), OBJC_ASSOCIATION_RETAIN);
    [self shouldObserveEditingChange];
}

- (GKTextType)gk_textType
{
    NSNumber *number = objc_getAssociatedObject(self, &GKTextTypeKey);
    return number ? [number unsignedIntegerValue] : GKTextTypeAll;
}

- (void)setCa_textDidChange:(void (^)(void))gk_textDidChange
{
    objc_setAssociatedObject(self, &GKTextDidChangeKey, gk_textDidChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))gk_textDidChange
{
    return objc_getAssociatedObject(self, &GKTextDidChangeKey);
}

- (void)setCa_extraString:(NSString *) extraString
{
    objc_setAssociatedObject(self, &GKExtraStringKey, extraString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self shouldObserveEditingChange];
}

- (NSString*)gk_extraString
{
    return objc_getAssociatedObject(self, &GKExtraStringKey);
}

///获取光标位置
- (NSRange)gk_selectedRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

///设置光标位置
- (void)setCa_selectedRange:(NSRange) range
{
    UITextPosition *start = [self positionFromPosition:self.beginningOfDocument
                                                offset:range.location];
    UITextPosition *end = [self positionFromPosition:start
                                              offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    self.selectedTextRange = textRange;
}

- (void)setCa_forbiddenActions:(NSArray<NSString*>*) actions
{
    objc_setAssociatedObject(self, &GKForbiddenActionsKey, actions, OBJC_ASSOCIATION_RETAIN);
}

- (NSArray<NSString*>*)gk_forbiddenActions
{
    return objc_getAssociatedObject(self, &GKForbiddenActionsKey);
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *actions = self.gk_forbiddenActions;
    if(actions.count > 0){
        if([actions containsObject:NSStringFromSelector(action)]){
            return NO;
        }
    }
    
    if(action == @selector(paste:)){
        return YES;
    }
    
    if(self.text.length > 0){
        NSRange range = self.gk_selectedRange;
        if(range.length > 0){
            if(action == @selector(cut:) || action == @selector(copy:) || action == @selector(selectAll:)){
                return YES;
            }
        }else{
            if(action == @selector(select:) || action == @selector(selectAll:)){
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark- Edit change

///是否需要监听输入变化
- (void)shouldObserveEditingChange
{
    SEL action = @selector(textFieldTextDidChange:);
    if(!(self.gk_textType & GKTextTypeAll) || self.gk_maxLength > 0){
        if(![self targetForAction:action withSender:self]){
            [self addTarget:self action:action forControlEvents:UIControlEventEditingChanged];
        }
    }else{
        [self removeTarget:self action:action forControlEvents:UIControlEventEditingChanged];
    }
}

///文字输入改变
- (void)textFieldTextDidChange:(UITextField*) textField
{
    NSString *text = textField.text;
    
    //有输入法情况下忽略
    if(!textField.markedTextRange && text.length != 0){
        
        GKTextType type = textField.gk_textType;
        
        NSUInteger maxLength = textField.gk_maxLength;
        NSRange range = textField.gk_selectedRange;
        
        if([text isEqualToString:@"."]){
            textField.text = @"";
            return;
        }
        
        //小数
        if(type == GKTextTypeDecimal){
            NSUInteger pointIndex = [text gk_lastIndexOfCharacter:'.'];
            if(pointIndex != NSNotFound){
                //有多个点，删除前面的点
                NSRange pointRange = [text rangeOfString:@"."];
                if(pointRange.location != pointIndex){
                    NSString *result = [text stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, pointIndex)];
                    if(pointRange.location < range.location){
                        range.location -= text.length - result.length;
                    }
                    text = result;
                }
            }
        }
        
        //额外的字符串
        NSString *extraString = self.gk_extraString;
        if(extraString.length > 0 && text.length >= extraString.length){
            if([text isEqualToString:extraString]){
                textField.text = @"";
                return;
            }else{
                NSRange extraRange = NSMakeRange(text.length - extraString.length, extraString.length);
                NSString *extra = [text substringWithRange:extraRange];
                if([extra isEqualToString:extraString]){
                    text = [text stringByReplacingCharactersInRange:extraRange withString:@""];
                }
            }
        }
        
        text = [text gk_stringByFilterWithType:type];
        if(range.location > text.length){
            range.location = text.length;
        }
        
        //删除超过长度的字符串
        if(text.length > maxLength){
            NSUInteger length = text.length - maxLength;
            
            //NSUInteger 没有负值
            NSUInteger location = range.location >= length ? range.location - length : 0;
            
            range.location = location;
            text = [text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
        }

        //添加额外字符串
        if(text.length > 0 && extraString.length > 0){
            text = [text stringByAppendingString:extraString];
            if(range.location > text.length - extraString.length){
                range.location = text.length - extraString.length;
            }
        }
        
        textField.text = text;
        if(range.location > text.length){
            range.location = text.length;
        }
        if(range.location + range.length > text.length){
            range.length = text.length - range.location;
        }
        textField.gk_selectedRange = range;
    }
    !self.gk_textDidChange ?: self.gk_textDidChange();
}

@end
