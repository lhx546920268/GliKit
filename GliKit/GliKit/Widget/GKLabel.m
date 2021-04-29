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

///URL 正则表达式识别器
static NSRegularExpression *URLRegularExpression = nil;

@interface GKLabel ()

///长按手势
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

///可点击的位置 rangeValue
@property(nonatomic, strong) NSMutableArray<NSValue*> *clickableRanges;

///文字绘制区域
@property(nonatomic, assign) CGRect textDrawRect;

///URL 正则表达式识别器
@property(nonatomic, readonly) NSRegularExpression *URLRegularExpression;

///点击时高亮区域 CGRectValue
@property(nonatomic, strong) NSArray<NSValue*> *highlightedRects;

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
    if(size.width != UIViewNoIntrinsicMetric && size.width < 2777777){
        size.width += _contentInsets.left + _contentInsets.right;
    }
    
    if(size.width != UIViewNoIntrinsicMetric && size.height < 2777777){
        size.height += _contentInsets.top + _contentInsets.bottom;
    }
    
    return size;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect drawRect = UIEdgeInsetsInsetRect(rect, _contentInsets);
    self.textDrawRect = drawRect;
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
    return _menuItems ? _menuItems : @[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copy:)]];
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if(self.canPerformActionHandler){
        return self.canPerformActionHandler(action, sender);
    }
    
    //只显示自己的
    return action == @selector(copy:);
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
    return [self detectURLForText:text];
}

// MARK: - URL Detect

- (void)setShouldDetectURL:(BOOL)shouldDetectURL
{
    if(_shouldDetectURL != shouldDetectURL){
        _shouldDetectURL = shouldDetectURL;
        if(_shouldDetectURL){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            self.userInteractionEnabled = YES;
            [self addGestureRecognizer:tap];
        }else{
            [_clickableRanges removeAllObjects];
        }
    }
}

- (NSRegularExpression *)URLRegularExpression
{
    if(!URLRegularExpression){
        
        NSString *allCharacter = @"[a-zA-Z0-9_.-~!@#$%^&*+?:/=]"; //所有字符
        
        NSString *scheme = @"((http[s]?|ftp)://)?"; //协议 可选
        NSString *user = [NSString stringWithFormat:@"(%@+@)?", allCharacter]; //用户 密码
        NSString *host = @"([a-zA-Z0-9_-]+\\.)+[a-zA-Z]{2,6}"; //主机
        NSString *port = @"(:\\d+)?"; //端口
        NSString *path = [NSString stringWithFormat:@"(/%@+)*", allCharacter]; //路径
        NSString *parameterString = [NSString stringWithFormat:@"(;%@+)*", allCharacter]; //参数
        NSString *query = [NSString stringWithFormat:@"(\\?%@+)*", allCharacter]; //查询参数
        
        NSString *pattern = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", scheme, user, host, port, path, parameterString, query];
        URLRegularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return URLRegularExpression;
}

///识别链接
- (id)detectURLForText:(id) text
{
    if(self.shouldDetectURL){
        [_clickableRanges removeAllObjects];
        NSString *str = text;
        if([text isKindOfClass:NSAttributedString.class]){
            str = [(NSAttributedString*)text string];
        }
        
        NSArray *results = nil;
        if(![NSString isEmpty:str]){
            results = [self.URLRegularExpression matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        }
        
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
                [attr addAttributes:self.clickableAttributes range:result.range];
            }
            text = attr;
        }
    }
    
    return text;
}

// MARK: - Clickable

- (NSDictionary *)clickableAttributes
{
    if(_clickableAttributes.count == 0){
        _clickableAttributes = @{NSForegroundColorAttributeName: UIColor.systemBlueColor, NSUnderlineStyleAttributeName: @(YES)};
    }
    return _clickableAttributes;
}

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
    if(range.location + range.length < text.length){
        [self.clickableRanges addObject:[NSValue valueWithRange:range]];
    }
}

///处理点击
- (void)handleTap:(UITapGestureRecognizer*) tap
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeHighlightedRects) object:nil];
    CGPoint point = [tap locationInView:self];
    NSRange range = [self clickableStringAtPoint:point];
    if(range.location != NSNotFound){
        !self.clickStringHandler ?: self.clickStringHandler([self.text substringWithRange:range]);
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
    point = CGPointMake(point.x, textRect.size.height - point.y);

    //行数为0
    NSAttributedString *attr = self.attributedText;
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attr);
    if(ctFrameSetter == NULL){
        return range;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.textDrawRect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, attr.length), path, NULL);
    CGPathRelease(path);
    
    if(ctFrame == NULL){
        CFRelease(ctFrameSetter);
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

            if (lineOrigin.y - lineDescent - self.contentInsets.top < point.y){
                break;
            }
        }

        if(lineIndex < numberOfLines){
            //获取行信息
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

            //把坐标转成行对应的坐标
            CGPoint position = CGPointMake(point.x - lineOrigin.x - self.contentInsets.left, point.y - lineOrigin.y);
            
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

    CFRelease(ctFrameSetter);
    CFRelease(ctFrame);
    
    return range;
}

//获取高亮区域
- (void)detectHighlightedRectsForRange:(NSRange) range ctFrame:(CTFrameRef) ctFrame;
{
    NSMutableArray *rects = nil;
    if(range.location != NSNotFound){
        rects = [NSMutableArray array];
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        
        NSInteger count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
        
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
                CGFloat endX = CTLineGetOffsetForStringIndex(line, innerRange.location + innerRange.length, NULL);
                
                CGPoint lineOrigin = lineOrigins[i];
                
                CGRect rect = CGRectMake(lineOrigin.x + startX + self.contentInsets.left, lineOrigin.y - lineDescent + self.contentInsets.top, endX - startX, lineAscent + lineDescent + lineLeading);
                
                //转成UIKit坐标
                rect.origin.y = self.textDrawRect.size.height - rect.origin.y - rect.size.height;
                
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
