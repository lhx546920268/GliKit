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
- (NSArray<NSTextCheckingResult*>*)matchesInString:(NSString*) string range:(NSRange) range;

@end

///URL识别器
@interface GKURLDetector : NSObject<GKTextDetector>

///单例
@property(class, nonatomic, readonly) GKURLDetector *sharedDetector;

@end

@class GKLabel;

@protocol GKLabelDelegate <NSObject>

@optional

///长按的时候是否可以执行某个方法
- (BOOL)label:(GKLabel*) label canPerformAction:(SEL) action withSender:(id) sender;

///点击某段文字了
- (void)label:(GKLabel*) label didClickTextAtRange:(NSRange) range;

@end

///自定义label，设置富文本时属性要全，包括对其方式，换行方式，字体等
///@warning 当有段落样式`NSParagraphStyle`时，换行模式必须设置成 `NSLineBreakByWordWrapping`，否则会导致计算错误
@interface GKLabel : UILabel

///文本边距 default `zero`
@property(nonatomic, assign) IBInspectable UIEdgeInsets contentInsets;

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

///当内容太多不够显示的时候，是否需要自动添加省略号，default `NO`，NSLineBreakByWordWrapping才生效
@property(nonatomic, assign) BOOL shouldAddTruncation;

///省略号
@property(nonatomic, copy) NSAttributedString *attributedTruncationString;

/// 添加可点击的位置，重新设置text会忽略以前添加的
/// @param range 可点击的位置，如果该范围不在text中，则忽略
- (void)addClickableRange:(NSRange) range;

@end

NS_ASSUME_NONNULL_END
