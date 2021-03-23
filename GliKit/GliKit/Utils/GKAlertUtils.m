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

+ (GKAlertController*)showAlertWithTitle:(id) title
                   message:(id) message
                      icon:(UIImage*) icon
              buttonTitles:(NSArray<NSString*>*) buttonTitles
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(GKAlertButtonDidClickHandler) handler
{
    return [GKAlertUtils showAlertControllerWithStyle:GKAlertStyleAlert title:title message:message icon:icon buttonTitles:buttonTitles cancelButtonTitle:nil destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (GKAlertController*)showActionSheetWithTitle:(id) title
                         message:(id) message
                            icon:(UIImage*) icon
                    buttonTitles:(NSArray<NSString*>*) buttonTitles
               cancelButtonTitle:(NSString*) cancelButtonTitle
                         handler:(GKAlertButtonDidClickHandler) handler
{
    return [GKAlertUtils showAlertControllerWithStyle:GKAlertStyleActionSheet title:title message:message icon:icon buttonTitles:buttonTitles cancelButtonTitle:cancelButtonTitle destructiveButtonIndex:NSNotFound handler:handler];
}

+ (GKAlertController*)showAlertWithTitle:(id)title handler:(GKAlertConfirmHandler)handler
{
    return [GKAlertUtils showAlertWithTitle:title message:nil destructiveButtonIndex:1 handler:handler];
}

+ (GKAlertController*)showAlertWithMessage:(id)message handler:(GKAlertConfirmHandler)handler
{
    return [GKAlertUtils showAlertWithTitle:nil message:message destructiveButtonIndex:1 handler:handler];
}

+ (GKAlertController*)showAlertWithTitle:(id)title destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
    return [GKAlertUtils showAlertWithTitle:title message:nil destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (GKAlertController*)showAlertWithMessage:(id)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
    return [GKAlertUtils showAlertWithTitle:nil message:message destructiveButtonIndex:destructiveButtonIndex handler:handler];
}

+ (GKAlertController*)showAlertWithTitle:(id)title message:(id)message destructiveButtonIndex:(NSInteger)destructiveButtonIndex handler:(GKAlertConfirmHandler)handler
{
    return [GKAlertUtils showAlertWithTitle:title message:message icon:nil buttonTitles:@[@"取消", @"确定"] destructiveButtonIndex:destructiveButtonIndex handler:^(NSInteger buttonIndex, NSString *title) {
        if(buttonIndex == 1){
            !handler ?: handler();
        }
    }];
}

+ (GKAlertController*)showAlertControllerWithStyle:(GKAlertStyle) style
                           title:(id) title
                   message:(id) message
                      icon:(UIImage*) icon
              buttonTitles:(NSArray<NSString*>*) buttonTitles
                   cancelButtonTitle:(NSString*) cancelButtonTitle
    destructiveButtonIndex:(NSInteger) destructiveButtonIndex
                   handler:(GKAlertButtonDidClickHandler) handler
{
    GKAlertController *alert = [[GKAlertController alloc] initWithTitle:title message:message icon:icon style:style cancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitles];
    alert.destructiveButtonIndex = destructiveButtonIndex;
    alert.selectHandler = ^(NSUInteger index) {
        NSString *title = index < buttonTitles.count ? buttonTitles[index] : cancelButtonTitle;
        !handler ?: handler(index, title);
    };
    [alert show];
    
    return alert;
}

@end
