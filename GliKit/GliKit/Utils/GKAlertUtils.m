//
//  GKAlertUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/4/9.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAlertUtils.h"
#import "GKAlertController.h"
#import "NSObject+GKUtils.h"

@implementation GKAlertUtils

+ (void)showAlertWithTitle:(NSString*) title
                   message:(NSString*) message
              buttonTitles:(NSArray<NSString*>*) buttonTitles
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(GKAlertButtonDidClickHandler) handler
{
    [GKAlertUtils showAlertControllerWithStyle:UIAlertControllerStyleAlert title:title message:message buttonTitles:buttonTitles cancelButtonTitle:nil destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (void)showActionSheetWithTitle:(NSString*) title
                         message:(NSString*) message
                    buttonTitles:(NSArray<NSString*>*) buttonTitles
               cancelButtonTitle:(NSString*) cancelButtonTitle
                         handler:(GKAlertButtonDidClickHandler) handler
{
    [GKAlertUtils showAlertControllerWithStyle:UIAlertControllerStyleActionSheet title:title message:message buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonIndex:NSNotFound handler:handler];
}

+ (void)showAlertWithTitle:(NSString *)title handler:(GKAlertConfirmHandler)handler
{
    [GKAlertUtils showAlertWithTitle:title message:nil destructiveButtonIndex:1 handler:handler];
}

+ (void)showAlertWithMessage:(NSString *)message handler:(GKAlertConfirmHandler)handler
{
    [GKAlertUtils showAlertWithTitle:nil message:message destructiveButtonIndex:1 handler:handler];
}

+ (void)showAlertWithTitle:(NSString *)title destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
    [GKAlertUtils showAlertWithTitle:title message:nil destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (void)showAlertWithMessage:(NSString *)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
     [GKAlertUtils showAlertWithTitle:nil message:message destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
    [GKAlertUtils showAlertWithTitle:title message:message buttonTitles:@[@"取消", @"确定"] destructiveButtonIndex:destructiveButtonIndex handler:^(NSInteger buttonIndex, NSString *title) {
        if(buttonIndex == 1){
            !handler ?: handler();
        }
    }];
}

+ (void)showAlertControllerWithStyle:(UIAlertControllerStyle) style
                           title:(NSString*) title
                   message:(NSString*) message
              buttonTitles:(NSArray<NSString*>*) buttonTitles
                   cancelButtonTitle:(NSString*) cancelButtonTitle
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(GKAlertButtonDidClickHandler) handler
{
    UIAlertController *controlelr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    for(NSInteger i = 0;i < buttonTitles.count;i ++){
        NSString *title = buttonTitles[i];
        [controlelr addAction:[UIAlertAction actionWithTitle:title style:destructiveButtonIndex == i ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !handler ?: handler(i, title);
        }]];
    }
    
    if(cancelButtonTitle){
        [controlelr addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            !handler ?: handler(buttonTitles.count, title);
        }]];
    }
    
    [NSObject.gkCurrentViewController presentViewController:controlelr animated:YES completion:nil];
}

@end
