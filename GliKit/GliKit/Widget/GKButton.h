//
//  GKButton.h
//  GliKit
//
//  Created by 罗海雄 on 2019/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///GKButton 图标位置
typedef NS_ENUM(NSInteger, GKButtonImagePosition){
    
    ///左边 系统默认
    GKButtonImagePositionLeft = 0,
    
    ///图标在文字右边
    GKButtonImagePositionRight,
    
    ///图标在文字顶部
    GKButtonImagePositionTop,
    
    ///图标在文字底部
    GKButtonImagePositionBottom,
};

///点击事件回调
typedef void(^GKButtonSingleClickHandler)(void);

/**
 自定义按钮  可设置按钮图标位置和间距，图标显示大小
 @warning UIControlContentHorizontalAlignmentFill 和 UIControlContentVerticalAlignmentFill 将忽略
 */
@interface GKButton : UIButton

///图标位置
@property(nonatomic, assign) GKButtonImagePosition imagePosition;

///图标和文字间隔
@property(nonatomic, assign) CGFloat imagePadding;

///图标大小 默认 zero,使用原来的大小
@property(nonatomic, assign) CGSize imageSize;

///避免重复点击阙值 default 0.2
@property(nonatomic, assign) NSTimeInterval singleClickTimeInterval;

///添加不可重复的点击事件
- (void)addSingleClickHandler:(GKButtonSingleClickHandler) handler;

///移除点击事件
- (void)removeSingleClickHandler:(GKButtonSingleClickHandler) handler;

@end

NS_ASSUME_NONNULL_END
