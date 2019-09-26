//
//  GKAlertViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewController.h"
#import "GKAlertAction.h"
#import "GKAlertProps.h"

NS_ASSUME_NONNULL_BEGIN

///弹窗样式
typedef NS_ENUM(NSUInteger, GKAlertControllerStyle)
{
    ///UIActionSheet 样式
    GKAlertControllerStyleActionSheet = 0,
    
    ///UIAlertView 样式
    GKAlertControllerStyleAlert = 1
};

/**
 弹窗控制器 AlertView 和 ActionSheet的整合
 @warning 在显示show前设置好属性
 */
@interface GKAlertController : GKBaseViewController

/**
 样式
 */
@property(nonatomic, readonly) GKAlertControllerStyle style;

/**
 弹窗属性 默认使用单例
 */
@property(nonatomic, strong) GKAlertProps *props;

/**
 具有警示意义的按钮 下标，default is ’NSNotFound‘，表示没有这个按钮
 */
@property(nonatomic, assign) NSUInteger destructiveButtonIndex;

/**
 是否关闭弹窗当点击某一个按钮的时候 default is 'YES'
 */
@property(nonatomic, assign) BOOL dismissWhenSelectButton;

/**
 按钮 不包含actionSheet 的取消按钮
 */
@property(nonatomic, readonly, copy) NSArray<GKAlertAction*> *alertActions;

/**
 点击回调 index 按钮下标 包含取消按钮 actionSheet 从上到下， alert 从左到右
 */
@property(nonatomic, copy, nullable) void(^selectionHandler)(NSUInteger index);

+ (instancetype)alertWithTitle:(nullable id) title
                       message:(nullable id) message
             cancelButtonTitle:(nullable NSString*) cancelButtonTitle
             otherButtonTitles:(nullable NSArray<NSString*>*) otherButtonTitles;

+ (instancetype)actionSheetWithTitle:(nullable id) title
                             message:(nullable id) message
                   otherButtonTitles:(nullable NSArray<NSString*>*) otherButtonTitles;

/**
 实例化一个弹窗
 @param title 标题 NSString 或者 NSAttributedString
 @param message 信息 NSString 或者 NSAttributedString
 @param icon 图标
 @param style 样式
 @param cancelButtonTitle 取消按钮 default is ‘取消’
 @param otherButtonTitles 按钮
 @return 一个实例
 */
- (instancetype)initWithTitle:(nullable id) title
                      message:(nullable id) message
                         icon:(nullable UIImage*) icon
                        style:(GKAlertControllerStyle) style
            cancelButtonTitle:(nullable NSString *) cancelButtonTitle
            otherButtonTitles:(nullable NSArray<NSString*>*) otherButtonTitles;

/**
 实例化一个弹窗
 @param title 标题 NSString 或者 NSAttributedString
 @param message 信息 NSString 或者 NSAttributedString
 @param icon 图标
 @param style 样式
 @param cancelButtonTitle 取消按钮 default is ‘取消’
 @param actions 按钮
 @return 一个实例
 */
- (instancetype)initWithTitle:(nullable id) title
                      message:(nullable id) message
                         icon:(nullable UIImage*) icon
                        style:(GKAlertControllerStyle) style
            cancelButtonTitle:(nullable NSString *) cancelButtonTitle
           otherButtonActions:(nullable NSArray<GKAlertAction*>*) actions;

/**
 更新某个按钮 不包含actionSheet 的取消按钮
 */
- (void)reloadButtonForIndex:(NSUInteger) index;

/**
 通过下标回去按钮标题
 */
- (nullable NSString*)buttonTitleForIndex:(NSUInteger) index;

/**
 显示弹窗
 */
- (void)show;

/**
 隐藏弹窗
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
