//
//  GKBadgeValueView.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///角标视图
@interface GKBadgeValueView : UIView

///是否自动调整尺寸 default `YES`
@property(nonatomic, assign) BOOL shouldAutoAdjustSize;

///角标最小尺寸 default `{15, 15}`
@property(nonatomic, assign) CGSize minimumSize;

///内容边距 default `UIEdgeInsetsMake(3, 5, 3, 5)`
@property(nonatomic, assign) UIEdgeInsets contentInsets;

///内部填充颜色 default `red`
@property(nonatomic, strong, null_resettable) UIColor *fillColor;

///边框颜色 default `clear`
@property(nonatomic, strong, null_resettable) UIColor *strokeColor;

///字体颜色 default 'white'
@property(nonatomic, strong, null_resettable) UIColor *textColor;

///字体 default `[UIFont appFontWithSize:13]`
@property(nonatomic, strong, null_resettable) UIFont *font;

///当前要显示的字符
@property(nonatomic, copy, nullable) NSString *value;

///是否要显示加号 当达到最大值时 default `NO`
@property(nonatomic, assign) BOOL shouldDisplayPlusSign;

///是否隐藏当 value = 0 时, default `YES`
@property(nonatomic, assign) BOOL hideWhenZero;

///显示的最大数字 default `99`
@property(nonatomic, assign) int max;

///是否是一个点 default `NO`
@property(nonatomic, assign) BOOL point;

///点的半径 当 point = YES 时有效 default `4.0`
@property(nonatomic, assign) CGFloat pointRadius;

@end

NS_ASSUME_NONNULL_END
