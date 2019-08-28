//
//  UIView+GKXibUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///基础视图xib扩展 可直接在xib上设置 圆角 边框
@interface UIView (GKXibUtils)

///圆角半径
@property(nonatomic, assign) IBInspectable CGFloat cornerRadius;

///边框
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;

///边框颜色
@property(nonatomic, strong) IBInspectable UIColor *borderColor;

///layer.maskToBounds
@property(nonatomic, assign) IBInspectable BOOL maskToBounds;

@end


