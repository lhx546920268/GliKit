//
//  GKAlertUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/9.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKAlertController;

///提示弹窗点击回调
typedef void(^GKAlertButtonDidClickHandler)(NSInteger buttonIndex, NSString *title);

///确认弹窗
typedef void(^GKAlertConfirmHandler)(void);

///提示框工具类
@interface GKAlertUtils : NSObject

///显示一个提示弹出
+ (GKAlertController*)showAlertWithTitle:(nullable NSString*) title
                   message:(nullable NSString*) message
                      icon:(nullable UIImage*) icon
              buttonTitles:(nullable NSArray<NSString*>*) buttonTitles
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(nullable GKAlertButtonDidClickHandler) handler;

///显示一个确认 取消弹窗
+ (GKAlertController*)showAlertWithMessage:(nullable NSString *)message
                     handler:(nullable GKAlertConfirmHandler)handler;

+ (GKAlertController*)showAlertWithTitle:(nullable NSString *)title
                   handler:(nullable GKAlertConfirmHandler)handler;

+ (GKAlertController*)showAlertWithTitle:(nullable NSString *)title
    destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                   handler:(nullable GKAlertConfirmHandler)handler;

+ (GKAlertController*)showAlertWithMessage:(nullable NSString *)message
      destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                     handler:(nullable GKAlertConfirmHandler)handler;

+ (GKAlertController*)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
    destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                   handler:(nullable GKAlertConfirmHandler)handler;



///显示一个actionSheet
+ (GKAlertController*)showActionSheetWithTitle:(nullable NSString*) title
                         message:(nullable NSString*) message
                            icon:(nullable UIImage*) icon
                    buttonTitles:(nullable NSArray<NSString*>*) buttonTitles
               cancelButtonTitle:(nullable NSString*) cancelButtonTitle
                         handler:(nullable GKAlertButtonDidClickHandler) handler;

@end

NS_ASSUME_NONNULL_END

