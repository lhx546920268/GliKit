//
//  GKMenuBarItem.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+GKUtils.h"

/**
 菜单按钮信息
 */
@interface GKMenuBarItem : NSObject

/**
 标题
 */
@property(nonatomic,copy) NSString *title;

/**
 按钮图标
 */
@property(nonatomic,strong) UIImage *icon;

/**
 选中按钮图标
 */
@property(nonatomic,strong) UIImage *selectedIcon;

/**
 图标和标题的间隔
 */
@property(nonatomic,assign) CGFloat iconPadding;

/**
 自定义视图
 */
@property(nonatomic,strong) UIView *customView;

/**
 图标位置 default is 'GKButtonImagePositionLeft'
 */
@property(nonatomic,assign) GKButtonImagePosition iconPosition;

/**
 按钮背景图片
 */
@property(nonatomic,strong) UIImage *backgroundImage;

/**
 按钮边缘数据
 */
@property(nonatomic,copy) NSString *badgeNumber;

/**
 按钮宽度
 */
@property(nonatomic,assign) CGFloat itemWidth;

/**
 标题偏移量
 */
@property(nonatomic,assign) UIEdgeInsets titleInsets;

/**
 构造方法
 *@param title 标题
 *@return 已初始化的 GKMenuBarItem
 */
+ (instancetype)itemWithTitle:(NSString*) title;

@end


