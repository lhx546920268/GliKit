//
//  GKTextView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UITextView的子类，支持像UITextField那样的placeholder.
 */
@interface GKTextView : UITextView

/**
 当文本框中没有内容时，显示placeholder, default is 'nil'.
 */
@property(nonatomic, copy) NSString *placeholder;

/**
 placeholder 的字体颜色. default is 'UIColor.appPlaceholderColor'
 */
@property(nonatomic, strong) UIColor *placeholderTextColor;

/**
 placeholder的字体 默认和 输入框字体一样
 */
@property(nonatomic, strong) UIFont *placeholderFont;

/**
 placeholder画的起始位置 default is 'CGPointMake(8.0f, 8.0f)'
 */
@property(nonatomic, assign) CGPoint placeholderOffset;

/**
 最大输入数量 default is 'NSUIntegerMax'，没有限制
 */
@property(nonatomic, assign) NSUInteger maxLength;

/**
 是否需要显示 当前输入数量和 最大输入数量 当 maxLength = NSUIntegerMax 时，不显示，default is 'NO'
 */
@property(nonatomic, assign) BOOL shouldDisplayTextLength;

/**
 输入限制文字 属性
 */
@property(nonatomic, copy) NSDictionary *textLengthAttributes;

@end

