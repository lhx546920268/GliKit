//
//  GKPopoverMenu.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKPopover.h"

NS_ASSUME_NONNULL_BEGIN

@class GKButton;

///弹窗菜单按钮信息
@interface GKPopoverMenuItem : NSObject

///标题
@property(nonatomic, copy, nullable) NSString *title;

///按钮图标
@property(nonatomic, strong, nullable) UIImage *icon;

///通过 标题和 图标构造
+ (id)itemWithTitle:(nullable NSString*) title icon:(nullable UIImage*) icon;

@end

///弹窗按钮cell
@interface GKPopoverMenuCell : UITableViewCell

///按钮
@property(nonatomic, readonly) GKButton *button;

///分割线
@property(nonatomic, readonly) UIView *divider;

@end

@class GKPopoverMenu;

///弹窗菜单代理
@protocol GKPopoverMenuDelegate<GKPopoverDelegate>

///选择某一个
- (void)popoverMenu:(GKPopoverMenu*) popoverMenu didSelectAtIndex:(NSUInteger) index;

@end

///弹窗菜单 contentInsets 将设成 0
@interface GKPopoverMenu : GKPopover

///字体颜色 default `blackColor`
@property(nonatomic, strong) UIColor *textColor;

///字体 default `13`
@property(nonatomic, strong) UIFont *font;

///选中背景颜色 default `[UIColor colorWithWhite:0.95 alpha:1.0]`
@property(nonatomic, strong) UIColor *selectedBackgroundColor;

///图标和按钮的间隔 default `0.0`
@property(nonatomic, assign) CGFloat iconTitleInterval;

///菜单行高 default `30.0`
@property(nonatomic, assign) CGFloat rowHeight;

///菜单宽度 default `0`，会根据按钮标题宽度，按钮图标和 内容边距获取宽度
@property(nonatomic, assign) CGFloat menuWidth;

///cell 内容边距 default `(0, 15.0, 0, 15.0)` ，只有left和right生效
@property(nonatomic, assign) UIEdgeInsets cellContentInsets;

///分割线颜色 default `GKSeparatorColor`
@property(nonatomic, strong) UIColor *separatorColor;

///cell 分割线间距 default `(0, 0, 0, 0)` ，只有left和right生效
@property(nonatomic, assign) UIEdgeInsets separatorInsets;

///按钮信息
@property(nonatomic, strong, nonnull) NSArray<GKPopoverMenuItem*> *menuItems;

///标题
@property(nonatomic, copy) NSArray<NSString*> *titles;

///点击某个按钮回调
@property(nonatomic, copy, nullable) void(^selectHandler)(NSInteger index);

///代理
@property(nonatomic, weak, nullable) id<GKPopoverMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
