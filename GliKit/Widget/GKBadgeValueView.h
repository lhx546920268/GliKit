//
//  GKBadgeValueView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/2.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///角标视图
@interface GKBadgeValueView : UIView

/**
 是否自动调整大小 default is 'YES'
 */
@property(nonatomic, assign) BOOL shouldAutoAdjustSize;

/**
 角标最小大小 default is '{15, 15}'
 */
@property(nonatomic, assign) CGSize minimumSize;

/**
 内容边距 default is 'UIEdgeInsetsMake(3, 5, 3, 5)'
 */
@property(nonatomic, assign) UIEdgeInsets contentInsets;

/**
 内部填充颜色 default is '[UIColor redColor]'
 */
@property(nonatomic,strong) UIColor *fillColor;

/**
 边界颜色 default is '[UIColor clearColor]'
 */
@property(nonatomic,strong) UIColor *strokeColor;

/**
 字体颜色 default is '[UIColor whiteColor]'
 */
@property(nonatomic,strong) UIColor *textColor;

/**
 字体 default is [UIFont boldSystemFontOfSize:9];
 */
@property(nonatomic,strong) UIFont *font;

/**
 当前要显示的字符
 */
@property(nonatomic,copy) NSString *value;

/**
 是否要显示加号 当达到最大值时 default is NO
 */
@property(nonatomic,assign) BOOL shouldDisplayPlusSign;

/**
 是否隐藏当 value = 0 时, default is 'YES'
 */
@property(nonatomic,assign) BOOL hideWhenZero;

/**
 显示的最大数字 default is '99'
 */
@property(nonatomic,assign) int max;

/**
 是否是一个点 default is 'NO'
 */
@property(nonatomic,assign) BOOL point;

/**
 点的半径 当 point = YES 时有效 default is '4.0'
 */
@property(nonatomic,assign) CGFloat pointRadius;

@end

