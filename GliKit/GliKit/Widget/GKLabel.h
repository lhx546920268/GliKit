//
//  GKLabel.h
//  GliKit
//
//  Created by 罗海雄 on 2020/1/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///字符串识别器
@protocol GKTextDetector <NSObject>

///富文本属性
@property(nonatomic, copy, null_resettable) NSDictionary<NSAttributedStringKey, id> *attributes;

///匹配字符串
- (nullable NSArray<NSTextCheckingResult*>*)matchesInString:(nullable NSString*) string range:(NSRange) range;

@end

///URL识别器
@interface GKURLDetector : NSObject<GKTextDetector>

///单例
@property(class, nonatomic, readonly) GKURLDetector *sharedDetector;

@end

@class GKLabel;

///垂直对齐方式
typedef NS_ENUM(NSInteger, GKLabelVerticalAligment) {
    
    GKLabelVerticalAligmentCenter,
    GKLabelVerticalAligmentTop,
    GKLabelVerticalAligmentBottom
};

///代理
@protocol GKLabelDelegate <NSObject>

@optional

///长按的时候是否可以执行某个方法，默认只有 handleCopy
- (BOOL)label:(GKLabel*) label canPerformAction:(SEL) action withSender:(id) sender;

///点击某段文字了
- (void)label:(GKLabel*) label didClickTextAtRange:(NSRange) range;

@end

///自定义label，设置富文本时属性要全，包括对其方式，换行方式，字体等
///@warning 当有使用富文本有段落样式`NSParagraphStyle`时，换行模式必须设置成 `NSLineBreakByWordWrapping`，否则会导致计算错误
@interface GKLabel : UIView

///文本边距 default `zero`
@property(nonatomic, assign) UIEdgeInsets contentInsets;

///没有设置宽高约束的时候 要设置这个，用来自适应高度的
@property(nonatomic) CGFloat preferredMaxLayoutWidth;

// MARK: - 文字属性

///
@property(nonatomic, copy, nullable) NSString *text;

//富文本，必须使用CoreText的属性，比如用 kCTFontAttributeName，value可以用TextKit的
@property(nonatomic, copy, nullable) NSAttributedString *attributedText;

///default `appFontSize:15`
@property(nonatomic, strong, null_resettable) UIFont *font;

///default `blackColor`
@property(nonatomic, strong, null_resettable) UIColor *textColor;

///水平对齐方式 default `NSTextAlignmentNatural`
@property(nonatomic, assign) NSTextAlignment textAlignment;

///垂直对齐方式 default `GKLabelVerticalAligmentCenter`
@property(nonatomic, assign) GKLabelVerticalAligment verticalAligment;

///换行方式 default `NSLineBreakByTruncatingTail`
@property(nonatomic, assign) NSLineBreakMode lineBreakMode;

///省略号
@property(nonatomic, copy, nullable) NSAttributedString *attributedTruncationString;

///行数，类似UILabel default `0`
@property(nonatomic, assign) NSInteger numberOfLines;

// MARK: - 段落样式

///行距 default `0.0
@property(nonatomic, assign) CGFloat lineSpacing;

///识别器
@property(nonatomic, strong, nullable) id<GKTextDetector> textDetector;

///是否可以长按选中
@property(nonatomic, assign) BOOL selectable;

///选中时背景颜色 默认主题颜色 0.5透明度
@property(nonatomic, strong, null_resettable) UIColor *selectedBackgroundColor;

///显示的菜单按钮，默认是复制
@property(nonatomic, strong, null_resettable) NSArray<UIMenuItem*> *menuItems;

///代理
@property(nonatomic, weak) id<GKLabelDelegate> delegate;

/// 添加可点击的位置，重新设置text会忽略以前添加的
/// @param range 可点击的位置，如果该范围不在text中，则忽略
- (void)addClickableRange:(NSRange) range;

@end

NS_ASSUME_NONNULL_END
