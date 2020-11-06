//
//  GKScanBackgroundView.h
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///扫描背景
@interface GKScanBackgroundView : UIView

///扫描框位置大小
@property(nonatomic, readonly) CGRect scanBoxRect;

///扫描框大小
@property(nonatomic, assign) CGSize scanBoxSize;

///四角线条宽度 default is '5'
@property(nonatomic, assign) CGFloat cornerLineWidth;

///扫描区域改变
@property(nonatomic, copy, nullable) void(^scanBoxRectDidChange)(CGRect scanBoxRect);

///开始动画
- (void)startAnimating;

///停止动画
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
