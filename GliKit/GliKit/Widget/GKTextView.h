//
//  GKTextView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKTextView;

///代理
@protocol GKTextViewDelegate <UITextViewDelegate>

@optional

///输入内容超过限制了
- (void)textViewTextDidExceedsMaxLength:(GKTextView*) textView;

@end


///UITextView的子类，支持像UITextField那样的placeholder.
@interface GKTextView : UITextView

///当文本框中没有内容时，显示placeholder
@property(nonatomic, copy, nullable) NSString *placeholder;

///placeholder 的字体颜色. default `UIColor.appPlaceholderColor`
@property(nonatomic, strong, null_resettable) UIColor *placeholderTextColor;

///placeholder的字体 默认和 输入框字体一样
@property(nonatomic, strong, null_resettable) UIFont *placeholderFont;

///placeholder显示的起始位置 default `(8.0f, 8.0f)`
@property(nonatomic, assign) CGPoint placeholderOffset;

///最大输入数量 default `NSUIntegerMax`，没有限制
@property(nonatomic, assign) NSUInteger maxLength;

///是否需要显示 当前输入数量和 最大输入数量 当 maxLength = NSUIntegerMax 时，不显示，default `NO`
@property(nonatomic, assign) BOOL shouldDisplayTextLength;

///是否把一个表情当成一个长度 default NO
@property(nonatomic, assign) BOOL emojiAsOne;

///输入限制文字 属性
@property(nonatomic, copy, null_resettable) NSDictionary *textLengthAttributes;

///代理
@property(nonatomic, weak) id<GKTextViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
