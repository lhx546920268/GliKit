//
//  GKTextView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTextView.h"
#import "UIColor+GKTheme.h"
#import "NSString+GKUtils.h"
#import "UIColor+GKUtils.h"

@protocol UITextPasteConfigurationSupporting;

@interface GKTextView()<UITextPasteDelegate>

///文本串长度
@property(nonatomic, readonly) NSInteger textLength;

@end

@implementation GKTextView

@synthesize placeholderFont = _placeholderFont;
@synthesize placeholderTextColor = _placeholderTextColor;
@synthesize textLengthAttributes = _textLengthAttributes;
@dynamic delegate;

// MARK: - init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initProps];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initProps];
    }
    return self;
}

///初始化
- (void)initProps
{
    CGFloat inset = 5;
    self.textContainerInset = UIEdgeInsetsMake(8, inset, 8, inset);
    _maxLength = NSUIntegerMax;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gkTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
    
    self.font = [UIFont systemFontOfSize:14];
    self.placeholderOffset = CGPointMake(8.0f, 8.0f);
    self.textLengthAttributes = nil;
    self.pasteDelegate = self;
}

// MARK: - property

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updatePlaceholder];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updatePlaceholder];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (![placeholder isEqualToString:_placeholder]){
        _placeholder = [placeholder copy];
        [self updatePlaceholder];
    }
}

- (void)setPlaceholderFont:(UIFont *) font
{
    if(_placeholderFont != font){
        _placeholderFont = font;
        [self updatePlaceholder];
    }
}

- (UIFont *)placeholderFont {
    UIFont *font = _placeholderFont ? _placeholderFont : self.font;
    if(!font){
        font = [UIFont systemFontOfSize:14];
    }
    return font;
}

- (void)setPlaceholderTextColor:(UIColor *) textColor
{
    if(![_placeholderTextColor isEqualToColor:textColor]){
        _placeholderTextColor = textColor;
        [self updatePlaceholder];
    }
}

- (UIColor *)placeholderTextColor
{
    return _placeholderTextColor ? _placeholderTextColor : UIColor.gkPlaceholderColor;
}

- (void)setPlaceholderOffset:(CGPoint) offset
{
    if(!CGPointEqualToPoint(_placeholderOffset, offset)){
        _placeholderOffset = offset;
        [self updatePlaceholder];
    }
}

- (void)setMaxLength:(NSUInteger)maxLength
{
    if(_maxLength != maxLength){
        _maxLength = maxLength;
        [self updatePlaceholder];
    }
}

- (void)setShouldDisplayTextLength:(BOOL)shouldDisplayTextLength
{
    if(_shouldDisplayTextLength != shouldDisplayTextLength){
        _shouldDisplayTextLength = shouldDisplayTextLength;
        [self updatePlaceholder];
    }
}

- (void)setTextLengthAttributes:(NSDictionary *)attrs
{
    if(_textLengthAttributes != attrs){
        _textLengthAttributes = attrs;
        [self updatePlaceholder];
    }
}

- (NSDictionary *)textLengthAttributes
{
    if(_textLengthAttributes.count == 0){
        _textLengthAttributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:13],
            NSForegroundColorAttributeName: UIColor.lightGrayColor
        };
    }
    return _textLengthAttributes;
}

- (NSInteger)textLength
{
    return self.emojiAsOne ? self.text.gkLengthEmojiAsOne : self.text.length;
}

// MARK: - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

// MARK: - draw

///ios 9 在 iphone5s 上会出现一条横线
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //绘制placeholder
    if(![NSString isEmpty:self.placeholder] && self.text.length == 0){
        
        NSDictionary *attrs = @{
            NSFontAttributeName: self.placeholderFont,
            NSForegroundColorAttributeName: self.placeholderTextColor
        };
        CGRect rect = CGRectMake(_placeholderOffset.x, _placeholderOffset.y, width - _placeholderOffset.x * 2, height - _placeholderOffset.y * 2);
        [_placeholder drawInRect:rect withAttributes:attrs];
    }
    
    //绘制输入的文字数量和限制
    if(self.shouldDisplayTextLength && self.maxLength != NSUIntegerMax){
        
        CGFloat padding = 8;
        NSString *text = [self textByRemoveMarkedRange];
        NSInteger length = self.emojiAsOne ? text.gkLengthEmojiAsOne : text.length;
        NSString *string = [NSString stringWithFormat:@"%ld/%ld", length, self.maxLength];
        
        NSDictionary *attrs = self.textLengthAttributes;
        CGSize size = [string sizeWithAttributes:attrs];
        [string drawInRect:CGRectMake(width - size.width - padding, height - size.height - padding, size.width, size.height) withAttributes: attrs];
    }
}

///获取去除markedText的 text
- (NSString*)textByRemoveMarkedRange
{
    NSString *text = self.text;
    UITextRange *markedTextRange = self.markedTextRange;
    if(markedTextRange){
        const NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:markedTextRange.start];
        const NSInteger length = [self offsetFromPosition:markedTextRange.start toPosition:markedTextRange.end];
        
        NSRange range = NSMakeRange(location, length);
        text = [text stringByReplacingCharactersInRange:range withString:@""];
    }
    
    return text;
}

// MARK: - private method

///更新placeholder
- (void)updatePlaceholder
{
    [self setNeedsDisplay];
}

///文字输入改变
- (void)gkTextDidChange:(NSNotification *)notification
{
    [self updatePlaceholder];
    
    NSString *text = self.text;
    
    //有输入法情况下忽略
    NSInteger textLength = self.textLength;
    if(!self.markedTextRange && self.maxLength != NSUIntegerMax && textLength > self.maxLength){
        NSUInteger maxLength = self.maxLength;
        
        //删除超过长度的字符串
        NSUInteger length = textLength - maxLength;
        NSRange range = self.selectedRange;
        
        //NSUInteger 没有负值
        NSUInteger location = range.location >= length ? range.location - length : 0;
        
        range.location = location;
        text = [text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
        self.text = text;
        textLength = self.emojiAsOne ? text.gkLengthEmojiAsOne : text.length;
        if(range.location < textLength){
            self.selectedRange = range;
        }
        
        if ([self.delegate respondsToSelector:@selector(textViewTextDidExceedsMaxLength:)]) {
            [self.delegate textViewTextDidExceedsMaxLength:self];
        }
    }
}

// MARK: - UITextPasteDelegate

///ios 11才有
- (BOOL)textPasteConfigurationSupporting:(id<UITextPasteConfigurationSupporting>)textPasteConfigurationSupporting shouldAnimatePasteOfAttributedString:(NSAttributedString *)attributedString toRange:(UITextRange *)textRange NS_AVAILABLE_IOS(11_0)
{
    return false;
}


@end
