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
#import <CoreText/CoreText.h>
#import "UIColor+GKUtils.h"
#import "UIViewController+GKPush.h"
#import <NSAttributedString+GKUtils.h>

///URL 正则表达式识别器
static NSRegularExpression *URLRegularExpression = nil;

@interface GKURLDetector ()

///URL 正则表达式识别器
@property(nonatomic, strong) NSRegularExpression *regularExpression;

@end

@implementation GKURLDetector

@synthesize attributes = _attributes;

+ (GKURLDetector *)sharedDetector
{
    static GKURLDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [GKURLDetector new];
    });
    
    return detector;
}

- (NSDictionary<NSAttributedStringKey,id> *)attributes
{
    if(!_attributes){
        _attributes = @{NSForegroundColorAttributeName: UIColor.systemBlueColor, NSUnderlineStyleAttributeName: @(YES)};
    }
    return _attributes;
}

- (NSRegularExpression *)regularExpression
{
    if(!_regularExpression){
        
        NSString *allCharacter = @"[0-9a-zA-Z!\\$&'\\(\\)\\*\\+,\\-\\.:;=\\?@\\[\\]_~]";
        NSString *scheme = @"((http[s]?)://)?"; //协议 可选
        NSString *host = [NSString stringWithFormat:@"((%@+\\.){2,}[a-zA-Z]{2,6}\\b)", allCharacter]; //主机

        NSString *path = @"[#%/0-9a-zA-Z!\\$&'\\(\\)\\*\\+,\\-\\.:;=\\?@\\[\\]_~]*"; //路径
        
        NSString *pattern = [NSString stringWithFormat:@"%@%@%@", scheme, host, path];
        _regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return _regularExpression;
}

- (NSArray<NSTextCheckingResult *> *)matchesInString:(NSString *)string range:(NSRange)range
{
    if ([NSString isEmpty:string]) return nil;
    return [self.regularExpression matchesInString:string options:0 range:range];
}

@end

@interface GKLabel ()

///长按手势
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

///点击手势
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;

///可点击的位置 rangeValue
@property(nonatomic, strong) NSMutableArray<NSValue*> *clickableRanges;

///文字绘制区域
@property(nonatomic, assign) CGRect textDrawRect;

///点击时高亮区域 CGRectValue
@property(nonatomic, strong) NSArray<NSValue*> *highlightedRects;

///coreText
@property(nonatomic, assign) CTFramesetterRef framesetter;

///省略号宽度
@property(nonatomic, assign) CGFloat truncationWidth;

@end

@implementation GKLabel

@synthesize framesetter = _framesetter;

// MARK: - CoreText

- (CTFramesetterRef)framesetter
{
    if (!_framesetter) {
        NSAttributedString *attr = self.attributedText;
        if (attr) {
            //富文本没有字体，加上字体
            if ([attr attribute:NSFontAttributeName atIndex:0 effectiveRange:nil] == nil) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attr];
                [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedString.length)];
                attr = attributedString;
            }
            _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attr);
        }
    }
    return _framesetter;
}

- (void)setFramesetter:(CTFramesetterRef)framesetter
{
    if (_framesetter != framesetter) {
        if (_framesetter != NULL)
            CFRelease(_framesetter);
        _framesetter = framesetter;
    }
}

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
    if(size.width != UIViewNoIntrinsicMetric && size.width < 2777777){
        size.width += _contentInsets.left + _contentInsets.right;
    }
    
    if(size.width != UIViewNoIntrinsicMetric && size.height < 2777777){
        size.height += _contentInsets.top + _contentInsets.bottom;
    }
    
    return size;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    //计算间距和垂直对齐
    bounds.origin.x = _contentInsets.left;
    bounds.size.width -= _contentInsets.left + _contentInsets.right;
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAligment) {
        case GKLabelVerticalAligmentTop :
            rect.origin.y = MAX(bounds.origin.y, _contentInsets.top);
            break;
        case GKLabelVerticalAligmentCenter :
            rect.origin.y = MAX(bounds.origin.y, bounds.origin.y + (bounds.size.height - rect.size.height) / 2);
            break;
        case GKLabelVerticalAligmentBottom :
            rect.origin.y = CGRectGetMaxY(bounds) - rect.size.height - _contentInsets.bottom;
            break;
    }
    
    rect.origin.x = bounds.origin.x;
    rect.size.width = bounds.size.width;
    
    return rect;
}

- (void)drawTextInRect:(CGRect)rect
{
    self.truncationWidth = 0;
    CGRect drawRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    self.textDrawRect = drawRect;
    [super drawTextInRect:drawRect];
    
    //绘制省略号
    if (!self.shouldAddTruncation || self.lineBreakMode != NSLineBreakByWordWrapping || self.framesetter == NULL || [NSString isEmpty:self.text]) {
        return;
    }
    
    NSAttributedString *attr = self.attributedText;

    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, CFRangeMake(0, attr.length), NULL, drawRect.size, NULL);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, ceil(MAX(size.width, drawRect.size.width)), ceil(MAX(size.height, drawRect.size.height))));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, attr.length), path, NULL);
    CGPathRelease(path);

    if (ctFrame == NULL)
        return;
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex numberOfLines = CFArrayGetCount(lines);
    
    if (numberOfLines > 0) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, numberOfLines - 1);
        CFRange range = CTLineGetStringRange(line);
        
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        CFIndex position = range.location + range.length - 1;

        NSAttributedString *attributedTruncationString = self.attributedTruncationString;
        if (!attributedTruncationString) {
            NSString *truncationTokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
            NSMutableDictionary *attributes = [attr attributesAtIndex:(NSUInteger)position effectiveRange:NULL];
            if (![attributes isKindOfClass:NSMutableDictionary.class]) {
                attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
            }
            if (attributes[NSFontAttributeName] == nil) {
                attributes[NSFontAttributeName] = self.font;
            }
            if (attributes[NSForegroundColorAttributeName] == nil) {
                attributes[NSForegroundColorAttributeName] = self.textColor;
            }
            
            attributedTruncationString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:attributes];
        }
        self.truncationWidth = [attributedTruncationString gkBoundsWithConstraintWidth:drawRect.size.width].width;
        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTruncationString);
        
        //最后一行和省略号拼接起来 计算是否需要显示省略号
        NSMutableAttributedString *lastLineAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:
                                                       [attr attributedSubstringFromRange:
                                                        NSMakeRange((NSUInteger)range.location,
                                                                    (NSUInteger)range.length)]];
        [lastLineAttributedString appendAttributedString:attributedTruncationString];
        CTLineRef lastLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)lastLineAttributedString);

        //如果内容较少，这个会返回NULL，不需要绘制省略号
        CTLineRef truncatedLine = CTLineCreateTruncatedLine(lastLine, rect.size.width, truncationType, truncationLine);
        if (truncatedLine != NULL) {
            CGContextRef c = UIGraphicsGetCurrentContext();
            CGContextSaveGState(c);
            {
                //翻转context，因为coreText的坐标系和UIKit的坐标系不一样
                CGContextSetTextMatrix(c, CGAffineTransformIdentity);
                CGContextTranslateCTM(c, 0.0f, drawRect.size.height);
                CGContextScaleCTM(c, 1.0f, -1.0f);

                CGPoint lineOrigins[numberOfLines];
                CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLines), lineOrigins);
                
                CGFloat descent = 0.0f;
                CTLineGetTypographicBounds((CTLineRef)line, NULL, &descent, NULL);
                CGPoint lineOrigin = lineOrigins[numberOfLines - 1];
                
                CGFloat endX = CTLineGetOffsetForStringIndex(line, range.location + range.length, NULL);
                CGContextSetTextPosition(c, endX, lineOrigin.y - descent - self.font.descender);

                CTLineDraw(truncationLine, c);
            }
            CGContextRestoreGState(c);
            CFRelease(truncatedLine);
        }
    }

    CFRelease(ctFrame);
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
            self.userInteractionEnabled = YES;
        }

        self.longPressGesture.enabled = _selectable;
        if(_selectable){
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleWillHideMenuNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
        }else{
            [NSNotificationCenter.defaultCenter removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
        }
    }
}

- (UIColor *)selectedBackgroundColor
{
    if(!_selectedBackgroundColor){
        _selectedBackgroundColor = [UIColor.gkThemeColor gkColorWithAlpha:0.5];
    }
    return _selectedBackgroundColor;
}

- (NSArray<UIMenuItem *> *)menuItems
{
    return _menuItems ? _menuItems : @[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(handleCopy:)]];
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_framesetter != NULL)
        CFRelease(_framesetter);
}

- (void)drawRect:(CGRect)rect
{
    if(self.highlightedRects.count > 0){
        //绘制高亮状态
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, self.selectedBackgroundColor.CGColor);
        for(NSValue *value in self.highlightedRects){
            CGContextAddRect(context, value.CGRectValue);
        }
        CGContextFillPath(context);
        
        CGContextRestoreGState(context);
    }
    
    [super drawRect:rect];
}

- (void)setHighlightedRects:(NSArray<NSValue *> *)highlightedRects
{
    if(_highlightedRects != highlightedRects){
        _highlightedRects = highlightedRects;
        [self setNeedsDisplay];
    }
}

// MARK: - 通知

///菜单按钮将要消失
- (void)handleWillHideMenuNotification:(NSNotification*) notification
{
    self.highlightedRects = nil;
}

// MARK: - action

///长按
- (void)handleLongPress:(UILongPressGestureRecognizer*) longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan){
        [self showMenuItems];
    }
}

///复制
- (void)handleCopy:(id)sender
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
    CGRect highlightedRect = self.textDrawRect;
    self.highlightedRects = @[@(highlightedRect)];
    
    //显示菜单
    [self becomeFirstResponder];
    UIMenuController *controller = [UIMenuController sharedMenuController];
    controller.menuItems = self.menuItems;
    
    if(@available(iOS 13, *)){
        [controller showMenuFromView:self rect:highlightedRect];
    }else{
        [controller setTargetRect:highlightedRect inView:self];
        [controller setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.delegate respondsToSelector:@selector(label:canPerformAction:withSender:)]){
        return [self.delegate label:self canPerformAction:action withSender:sender];
    }
    
    //只显示自己的
    return action == @selector(handleCopy:);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// MARK: - Text

- (void)setText:(NSString *)text
{
    id result = [self handleTextChange:text];
    if([result isKindOfClass:NSString.class]){
        [super setText:result];
    }else{
        [super setAttributedText:result];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:[self handleTextChange:attributedText]];
}

///文字改变
- (id)handleTextChange:(id) text
{
    self.framesetter = nil;
    return [self detectText:text];
}

// MARK: - URL Detect

- (void)setTextDetector:(id<GKTextDetector>)textDetector
{
    if(_textDetector != textDetector){
        _textDetector = textDetector;
        if(_textDetector){
            [self addTapGestureRecognizerIfNeeded];
        }else{
            [_clickableRanges removeAllObjects];
        }
    }
}

- (void)addTapGestureRecognizerIfNeeded
{
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.tapGesture];
    }
    self.userInteractionEnabled = YES;
}

///识别文字
- (id)detectText:(id) text
{
    if(self.textDetector){
        [_clickableRanges removeAllObjects];
        NSString *str = text;
        if([text isKindOfClass:NSAttributedString.class]){
            str = [(NSAttributedString*)text string];
        }
        
        NSArray *results = [self.textDetector matchesInString:str range:NSMakeRange(0, str.length)];;
        
        if(results.count > 0){
            NSMutableAttributedString *attr = nil;
            if([text isKindOfClass:NSAttributedString.class]){
                attr = [[NSMutableAttributedString alloc] initWithAttributedString:text];
            }else{
                attr = [[NSMutableAttributedString alloc] initWithString:text];
                [attr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attr.length)];
                [attr addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, attr.length)];
            }
            
            for(NSTextCheckingResult *result in results){
                [self.clickableRanges addObject:[NSValue valueWithRange:result.range]];
                [attr addAttributes:self.textDetector.attributes range:result.range];
            }
            text = attr;
        }
    }
    
    return text;
}

// MARK: - Clickable

- (NSMutableArray<NSValue *> *)clickableRanges
{
    if(!_clickableRanges){
        _clickableRanges = [NSMutableArray array];
    }
    return _clickableRanges;
}

- (void)addClickableRange:(NSRange) range
{
    NSString *text = self.text;
    if(range.location + range.length <= text.length){
        [self addTapGestureRecognizerIfNeeded];
        [self.clickableRanges addObject:[NSValue valueWithRange:range]];
    }
}

///处理点击
- (void)handleTap:(UITapGestureRecognizer*) tap
{
    if (_clickableRanges.count == 0 || self.framesetter == NULL) return;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeHighlightedRects) object:nil];
    CGPoint point = [tap locationInView:self];
    NSRange range = [self clickableStringAtPoint:point];
    if(range.location != NSNotFound && range.length > 0){
        if ([self.delegate respondsToSelector:@selector(label:didClickTextAtRange:)]) {
            [self.delegate label:self didClickTextAtRange:range];
        }
        [self performSelector:@selector(removeHighlightedRects) withObject:nil afterDelay:0.3];
    }
}

///获取点中的字符串
- (NSRange)clickableStringAtPoint:(CGPoint) point
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    if([NSString isEmpty:self.text]){
        return range;
    }
    
    //判断点击处是否在文本内
    CGRect textRect = self.textDrawRect;
    if (!CGRectContainsPoint(textRect, point)){
        return range;
    }

    //转换成coreText 坐标
    point = CGPointMake(point.x - textRect.origin.x, textRect.size.height - (point.y - textRect.origin.y));

    //行数为0
    NSAttributedString *attr = self.attributedText;
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, CFRangeMake(0, attr.length), NULL, textRect.size, NULL);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, ceil(MAX(size.width, textRect.size.width)), ceil(MAX(size.height, textRect.size.height))));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, attr.length), path, NULL);
    CGPathRelease(path);

    if(ctFrame == NULL){
        return range;
    }

    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex numberOfLines = CFArrayGetCount(lines);

    if (numberOfLines > 0){
        //行起点
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);

        //获取点击的行的位置，数组是倒序的
        CFIndex lineIndex;
        for(lineIndex = 0;lineIndex < numberOfLines;lineIndex ++){
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            CGFloat lineDescent;
            CTLineGetTypographicBounds(line, NULL, &lineDescent, NULL);

            if (lineOrigin.y - lineDescent < point.y){
                break;
            }
        }

        if(lineIndex < numberOfLines){
            //获取行信息
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

            //把坐标转成行对应的坐标
            CGPoint position = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);

            //获取该点的字符位置，返回下一个输入的位置，比如点击的文字下标是0时，返回1
            CFIndex index = CTLineGetStringIndexForPosition(line, position);

            //检测字符位置是否超出该行字符的范围，有时候行的末尾不够现实一个字符了，点击该空旷位置时无效
            CFRange stringRange = CTLineGetStringRange(line);

            //获取整段文字中charIndex位置的字符相对line的原点的x值
            CGFloat offset = CTLineGetOffsetForStringIndex(line, index, NULL);

            if(position.x <= offset){
                index --;
            }

            if(index < stringRange.location + stringRange.length){
                NSLog(@"%ld, %ld, %ld", index, stringRange.location, stringRange.length);
                //获取对应的可点信息
                for(NSValue *result in self.clickableRanges){
                    NSRange rangeValue = result.rangeValue;
                    if(index >= rangeValue.location && index < rangeValue.location + rangeValue.length){
                        range = rangeValue;
                        break;
                    }
                }
            }
        }
    }

    [self detectHighlightedRectsForRange:range ctFrame:ctFrame];

    CFRelease(ctFrame);

    return range;
}

//获取高亮区域
- (void)detectHighlightedRectsForRange:(NSRange) range ctFrame:(CTFrameRef) ctFrame;
{
    NSMutableArray *rects = nil;
    if(range.location != NSNotFound && ![self.selectedBackgroundColor isEqualToColor:UIColor.clearColor]){
        rects = [NSMutableArray array];
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        
        NSInteger count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
        
        CGFloat preY = 0;
        for(NSInteger i = 0;i < count;i ++){
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CFRange lineRange = CTLineGetStringRange(line);
            
            NSRange innerRange = [self innerRangeBetweenOne:range andSecond:NSMakeRange(lineRange.location == kCFNotFound ? NSNotFound : lineRange.location, lineRange.length)];
            
            if(innerRange.location != NSNotFound && innerRange.length > 0){
                CGFloat lineAscent;
                CGFloat lineDescent;
                CGFloat lineLeading;

                //获取文字排版
                CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
                CGFloat startX = CTLineGetOffsetForStringIndex(line, innerRange.location, NULL);
                CFIndex end = innerRange.location + innerRange.length;
                CGFloat endX = CTLineGetOffsetForStringIndex(line, end, NULL);
                
                CGPoint lineOrigin = lineOrigins[i];
                
                CGRect rect = CGRectMake(lineOrigin.x + startX, lineOrigin.y - lineDescent, endX - startX, lineAscent + lineDescent + lineLeading);
                
                //转成UIKit坐标
                rect.origin.y = CGRectGetMaxY(self.textDrawRect) - CGRectGetMaxY(rect);
                if (preY > 0 && preY < rect.origin.y) {
                    rect.size.height += rect.origin.y - preY;
                    rect.origin.y = preY;
                }
                rect.origin.x += self.textDrawRect.origin.x;
                
                //最后一行加上省略号
                if (i == count - 1 && end == lineRange.location + lineRange.length) {
                    rect.size.width += self.truncationWidth;
                }
                
                preY = CGRectGetMaxY(rect);
                [rects addObject:@(rect)];
            }else if(lineRange.location > range.location + range.length){
                break;
            }
        }
    }
    
    self.highlightedRects = rects;
}

///获取内部的range
- (NSRange)innerRangeBetweenOne:(NSRange) one andSecond:(NSRange) second
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    //交换
    if(one.location > second.location){
        NSRange tmp = one;
        one = second;
        second = tmp;
    }
    
    if(second.location < one.location + one.length){
        range.location = second.location;
        
        NSInteger end = MIN(one.location + one.length, second.location + second.length);
        range.length = end - range.location;
    }
    
    return range;
}

///取消高亮
- (void)removeHighlightedRects
{
    self.highlightedRects = nil;
}

@end
