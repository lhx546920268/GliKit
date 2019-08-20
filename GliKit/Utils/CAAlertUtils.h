//
//  GKAlertUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/9.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>

///提示弹窗点击回调
typedef void(^GKAlertButtonDidClickHandler)(NSInteger buttonIndex, NSString *title);

///确认弹窗
typedef void(^GKAlertConfirmHandler)(void);

///提示框工具类
@interface GKAlertUtils : NSObject

///显示一个提示弹出
+ (void)showAlertWithTitle:(NSString*) title
                   message:(NSString*) message
              buttonTitles:(NSArray<NSString*>*) buttonTitles
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(GKAlertButtonDidClickHandler) handler;

///显示一个确认 取消弹窗
+ (void)showAlertWithMessage:(NSString *)message handler:(GKAlertConfirmHandler)handler;
+ (void)showAlertWithTitle:(NSString *)title handler:(GKAlertConfirmHandler)handler;
+ (void)showAlertWithTitle:(NSString *)title destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler;
+ (void)showAlertWithMessage:(NSString *)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler;




///显示一个actionSheet
+ (void)showActionSheetWithTitle:(NSString*) title
                   message:(NSString*) message
              buttonTitles:(NSArray<NSString*>*) buttonTitles
    cancelButtonTitle:(NSString*) cancelButtonTitle
                   handler:(GKAlertButtonDidClickHandler) handler;

@end

