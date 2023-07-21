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
#import "NSAttributedString+GKUtils.h"
#import "UIFont+GKUtils.h"

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

static CGFloat GKFloatMax = 10000000.0;

///获取文字绘制flushFactor
CF_INLINE CGFloat GKGetFlushFactor(NSTextAlignment textAligment) {
    CGFloat flushFactor;
    switch (textAligment) {
        case NSTextAlignmentRight :
            flushFactor = 1.0;
            break;
        case NSTextAlignmentCenter :
            flushFactor = 0.5;
            break;
        case NSTextAlignmentLeft :
        case NSTextAlignmentJustified :
        case NSTextAlignmentNatural :
        default :
            flushFactor = 0.0;
            break;
    }
    return flushFactor;
}

///获取省略号位置
CF_INLINE CTLineTruncationType GKGetLineTruncationType(NSLineBreakMode lineBreakMode) {
    CTLineTruncationType truncationType;
    switch (lineBreakMode) {
        case NSLineBreakByTruncatingHead :
            truncationType = kCTLineTruncationStart;
            break;
        case NSLineBreakByTruncatingMiddle :
            truncationType = kCTLineTruncationMiddle;
            break;
        case NSLineBreakByTruncatingTail :
        default :
            truncationType = kCTLineTruncationEnd;
            break;
    }
    return truncationType;
}

///是否需要省略号
CF_INLINE BOOL GKNeedTruncation(NSLineBreakMode lineBreakMode) {
    switch (lineBreakMode) {
        case NSLineBreakByTruncatingTail :
        case NSLineBreakByTruncatingMiddle :
        case NSLineBreakByTruncatingHead :
            return YES;
        default:
            return NO;
    }
}

///获取内部的range
CF_INLINE NSRange GKGetInnerRange(NSRange range1, NSRange range2) {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    //交换
    if(range1.location > range2.location){
        NSRange tmp = range1;
        range1 = range2;
        range2 = tmp;
    }
    
    if(range2.location < range1.location + range1.length){
        range.location = range2.location;
        
        NSInteger end = MIN(range1.location + range1.length, range2.location + range2.length);
        range.length = end - range.location;
    }
    
    return range;
}

///转换CF和NS
CF_INLINE NSRange GKTranslateCFRange(CFRange range) {
    return NSMakeRange(range.location == kCFNotFound ? NSNotFound : range.location, range.length);
}

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
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    self.verticalAligment = GKLabelVerticalAligmentCenter;
    self.textAlignment = NSTextAlignmentNatural;
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_framesetter != NULL)
        CFRelease(_framesetter);
}

// MARK: - Props

- (UIFont *)font
{
    if (!_font) {
        _font = [UIFont appFontWithSize:15];
    }
    return _font;
}

- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = UIColor.blackColor;
    }
    return _textColor;
}

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

// MARK: - Text

- (void)setText:(NSString *)text
{
    if (!GKStringEqual(_text, text)) {
        _text = text;
        if (_text) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:_text];
            NSDictionary *attrs = @{
                (id)kCTFontAttributeName: self.font,
                (id)kCTForegroundColorAttributeName: self.textColor,
                (id)kCTParagraphStyleAttributeName: [self paragraphStyle]
            };
  
            [attr addAttributes:attrs range:NSMakeRange(0, attr.length)];
            _attributedText = [self detectText:attr];
        } else {
            self.attributedText = nil;
        }
        self.framesetter = nil;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (_attributedText != attributedText) {
        NSMutableAttributedString *attr = (NSMutableAttributedString*)attributedText;
        if (attributedText) {
            if (![attributedText isKindOfClass:NSMutableAttributedString.class]) {
                attr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
            }
            NSMutableDictionary *attrs = (NSMutableDictionary*)[attr attributesAtIndex:0 effectiveRange:nil];
            if (![attrs isKindOfClass:NSMutableDictionary.class]) {
                attrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
            }
            
            if (!attrs[(id)kCTFontAttributeName]) {
                attrs[(id)kCTFontAttributeName] = self.font;
            }
            
            if (!attrs[(id)kCTForegroundColorAttributeName]) {
                attrs[(id)kCTForegroundColorAttributeName] = self.textColor;
            }
            
            if (!attrs[(id)kCTParagraphStyleAttributeName]) {
                attrs[(id)kCTParagraphStyleAttributeName] = [self paragraphStyle];
            }
            [attr addAttributes:attrs range:NSMakeRange(0, attr.length)];
        }
        
        _attributedText = [self detectText:attr];;
        _text = _attributedText.string;
        self.framesetter = nil;
    }
}

///段落样式
- (NSMutableParagraphStyle*)paragraphStyle
{
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = self.lineSpacing;
    //多行模式Truncating大小会计算错误，只有一行大小
    style.lineBreakMode = self.numberOfLines == 1 ? self.lineBreakMode : NSLineBreakByWordWrapping;
    style.alignment = self.textAlignment;
    
    return style;
}

// MARK: - Size

- (CGSize)intrinsicContentSize
{
    if (self.framesetter) {
        CFRange range;
        CGSize constraintSize;
        if (self.preferredMaxLayoutWidth > 0 && self.numberOfLines != 1) {
            constraintSize = CGSizeMake(self.preferredMaxLayoutWidth - _contentInsets.left - _contentInsets.right, GKFloatMax);
            range = [self textRangeForSize:constraintSize];
        } else {
            range = CFRangeMake(0, 0);
            constraintSize = CGSizeMake(65354, GKFloatMax);
        }
        CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, range, NULL, constraintSize, NULL);
        size.height += _contentInsets.top + _contentInsets.bottom;
        size.width += _contentInsets.left + _contentInsets.right;
        
        return size;
    }
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

///计算文字范围
- (CFRange)textRangeForSize:(CGSize) size
{
    CFRange range = CFRangeMake(0, 0);
    if (self.numberOfLines != 0) {
        //根据行数计算高度
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef ctFrame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        
        if (ctFrame != NULL) {
            //获取最后一行的位置
            CFArrayRef lines = CTFrameGetLines(ctFrame);
            CFIndex numberOfLines = CFArrayGetCount(lines);
            if (numberOfLines > self.numberOfLines) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, self.numberOfLines - 1);
                CFRange stringRange = CTLineGetStringRange(line);
                range.length = stringRange.location + stringRange.length;
            }
        }
    }
    return range;
}

///计算限制的文字范围内的文字绘制区域
- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x = _contentInsets.left;
    bounds.size.width -= _contentInsets.left + _contentInsets.right;
    
    //限制行数
    CFRange textRange = [self textRangeForSize:bounds.size];
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, textRange, NULL, bounds.size, NULL);
    CGRect drawRect = CGRectMake(0, 0, MIN(bounds.size.width, ceil(size.width)), MIN(ceil(size.height), bounds.size.height));
    
    switch (self.verticalAligment) {
        case GKLabelVerticalAligmentTop :
            drawRect.origin.y = MAX(bounds.origin.y, _contentInsets.top);
            break;
        case GKLabelVerticalAligmentCenter :
            drawRect.origin.y = MAX(bounds.origin.y, bounds.origin.y + (bounds.size.height - drawRect.size.height) / 2);
            break;
        case GKLabelVerticalAligmentBottom :
            drawRect.origin.y = CGRectGetMaxY(bounds) - drawRect.size.height - _contentInsets.bottom;
            break;
    }
    
    drawRect.origin.x = bounds.origin.x;
    drawRect.size.width = bounds.size.width;
    
    return drawRect;
}

// MARK: - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    if(self.highlightedRects.count > 0){
        //绘制高亮状态
        CGContextSetFillColorWithColor(context, self.selectedBackgroundColor.CGColor);
        for(NSValue *value in self.highlightedRects){
            CGContextAddRect(context, value.CGRectValue);
        }
        CGContextFillPath(context);
    }
    [self drawTextInRect:rect context:context];
    CGContextRestoreGState(context);
    
    [super drawRect:rect];
}

///绘制文字
- (void)drawTextInRect:(CGRect)rect context:(CGContextRef) context
{
    self.truncationWidth = 0;
    if (self.framesetter == NULL)
        return;
    
    CGRect drawRect = [self textRectForBounds:rect];
    self.textDrawRect = drawRect;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, drawRect.size.width, drawRect.size.height));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);

    if (ctFrame == NULL)
        return;
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(ctFrame);
        return;
    }

    //翻转context，因为coreText的坐标系和UIKit的坐标系不一样
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    //根据文字绘制区域偏移
    CGContextTranslateCTM(context, drawRect.origin.x, CGRectGetMaxY(rect) - CGRectGetMaxY(drawRect));
    
    CGFloat flushFactor = GKGetFlushFactor(self.textAlignment);
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex i = 0; i < numberOfLines; i ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat penOffset = CTLineGetPenOffsetForFlush(line, flushFactor, CGRectGetWidth(drawRect));
        CGPoint lineOrigin = lineOrigins[i];
        CGContextSetTextPosition(context, penOffset, lineOrigin.y);
        
        if (i == numberOfLines - 1 && GKNeedTruncation(self.lineBreakMode)) {
            //绘制省略号
            CTLineRef truncatedLine = [self translateTruncatedLineFromLine:line];
            if (truncatedLine != NULL) {
                CTLineDraw(truncatedLine, context);
            } else {
                CTLineDraw(line, context);
            }
        } else {
            CTLineDraw(line, context);
        }
    }

    CFRelease(ctFrame);
}

///转换最后一行为省略号的
- (CTLineRef)translateTruncatedLineFromLine:(CTLineRef) line
{
    CFRange range = CTLineGetStringRange(line);
    NSAttributedString *attr = self.attributedText;
    if (range.location == kCFNotFound || range.length == 0 || range.location + range.length >= attr.length)
        return NULL;
 
    CFIndex position = range.location + range.length - 1;
    NSAttributedString *attributedTruncationString = self.attributedTruncationString;
    if (!attributedTruncationString) {
        NSString *truncationTokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
        NSDictionary *attributes = [attr attributesAtIndex:(NSUInteger)position effectiveRange:nil];
        attributedTruncationString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:attributes];
    }
    self.truncationWidth = [attributedTruncationString gkBoundsWithConstraintWidth:CGRectGetWidth(self.textDrawRect)].width;
    CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTruncationString);

    //最后一行和省略号拼接起来 计算是否需要显示省略号
    NSMutableAttributedString *lastLineAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:
                                                   [attr attributedSubstringFromRange:
                                                    NSMakeRange((NSUInteger)range.location,
                                                                (NSUInteger)range.length)]];
    if (range.length > 0) {
        //移除换行符
        unichar lastCharacter = [lastLineAttributedString.string characterAtIndex:range.length - 1];
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
            [lastLineAttributedString deleteCharactersInRange:NSMakeRange(range.length - 1, 1)];
        }
    }
    [lastLineAttributedString appendAttributedString:attributedTruncationString];
    CTLineRef lastLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)lastLineAttributedString);

    //如果内容较少，这个会返回NULL，不需要绘制省略号
    CTLineTruncationType truncationType = GKGetLineTruncationType(self.lineBreakMode);
    CTLineRef truncatedLine = CTLineCreateTruncatedLine(lastLine, CGRectGetWidth(self.textDrawRect), truncationType, truncationToken);
    CFRelease(truncationToken);
    CFRelease(lastLine);

    return truncatedLine != NULL ? CFAutorelease(truncatedLine) : NULL;
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

- (void)setHighlightedRects:(NSArray<NSValue *> *)highlightedRects
{
    if(_highlightedRects != highlightedRects){
        _highlightedRects = highlightedRects;
        [self setNeedsDisplay];
    }
}

///取消高亮
- (void)removeHighlightedRects
{
    self.highlightedRects = nil;
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

// MARK: - Text Detect

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
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.textDrawRect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
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
            
            NSRange innerRange = GKGetInnerRange(range, GKTranslateCFRange(lineRange));
            
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
                    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.textDrawRect)) {
                        rect.size.width = CGRectGetMaxX(self.textDrawRect) - rect.origin.x;
                    }
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

@end
