//
//  GKAlertButton.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///弹窗按钮
@interface GKAlertButton : UIView

/**
 标题
 */
@property(nonatomic,readonly) UILabel *titleLabel;

/**
 高亮显示视图
 */
@property(nonatomic,readonly) UIView *highlightView;

/**
 添加单击手势
 */
- (void)addTarget:(id) target action:(SEL) selector;

//方法
@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL selector;

@end
