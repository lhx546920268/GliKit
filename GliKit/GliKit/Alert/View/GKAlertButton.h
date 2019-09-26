//
//  GKAlertButton.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗按钮
@interface GKAlertButton : UIView

/**
 标题
 */
@property(nonatomic, readonly) UILabel *titleLabel;

/**
 高亮显示视图
 */
@property(nonatomic, readonly) UIView *highlightView;

/**
 添加单击手势
 */
- (void)addTarget:(nullable id) target action:(nullable SEL) selector;

//方法
@property(nonatomic, weak, nullable) id target;
@property(nonatomic, assign, nullable) SEL selector;

@end

NS_ASSUME_NONNULL_END
