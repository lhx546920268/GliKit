//
//  UIApplication+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/12/10.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UIApplication+GKUtils.h"
#import <objc/runtime.h>

static char GKDialogWindowKey;

@implementation UIApplication (GKUtils)

- (void)setDialogWindow:(UIWindow *)dialogWindow
{
    objc_setAssociatedObject(self, &GKDialogWindowKey, dialogWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)dialogWindow
{
    return objc_getAssociatedObject(self, &GKDialogWindowKey);
}

- (void)loadDialogWindowIfNeeded
{
    UIWindow *window = self.dialogWindow;
    if(!window){
        if(@available(iOS 13, *)){
            UIWindowScene *scene = nil;
              for(UIWindowScene *s in UIApplication.sharedApplication.connectedScenes){
                  if(s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:UIWindowScene.class]){
                      scene = s;
                      break;
                  }
              }
            if(scene){
                window = [[UIWindow alloc] initWithWindowScene:scene];
            }
        }
        if(!window){
            window = UIWindow.new;
        }
        window.frame = UIScreen.mainScreen.bounds;
        window.windowLevel = UIWindowLevelAlert;
        window.backgroundColor = UIColor.clearColor;
        [self setDialogWindow:window];
        [window makeKeyAndVisible];
    }
}

- (void)removeDialogWindowIfNeeded
{
    UIWindow *window = self.dialogWindow;
    if(window){
        if(!window.rootViewController){
            [window resignKeyWindow];
            [self setDialogWindow:nil];
        }
    }
}

@end
