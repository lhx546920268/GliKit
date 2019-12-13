//
//  UIView+GKStateUtils.h
//  AFNetworking
//
//  Created by 罗海雄 on 2019/12/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///状态 不支持多个状态并存，disable > highlighted > selected > normal 目前只对 UIButton UILabel UIImageView 有用
@interface UIView (GKStateUtils)

///状态背景
@property(nonatomic, readonly) NSMutableDictionary<NSNumber*,UIColor*> *gkBackgroundColorsForState;

///状态tintColor
@property(nonatomic, readonly) NSMutableDictionary<NSNumber*,UIColor*> *gkTintColorsForState;

///获取当前背景颜色
@property(nonatomic, readonly) UIColor *gkCurrentBackgroundColor;

///获取当前 tintColor
@property(nonatomic, readonly) UIColor *gkCurrentTintColor;

///当前装
@property(nonatomic, readonly) UIControlState gkState;

/**
 设置对应状态的背景颜色

 @param backgroundColor 背景颜色，为nil时移除
 @param state 状态，支持  UIControlStateNormal， UIControlStateHighlighted，UIControlStateDisabled，UIControlStateSelected
 */
- (void)gkSetBackgroundColor:(UIColor*) backgroundColor forState:(UIControlState) state;

/**
 设置对应状态的tintColor

 @param tintColor 颜色，为nil时移除
 @param state 状态，支持  UIControlStateNormal， UIControlStateHighlighted，UIControlStateDisabled，UIControlStateSelected
 */
- (void)gkSetTintColor:(UIColor*) tintColor forState:(UIControlState) state;


@end

@interface UIButton (GKStateUtils)

@end

@interface UIImageView (GKStateUtils)

@end

@interface UILabel (GKStateUtils)

@end

NS_ASSUME_NONNULL_END
