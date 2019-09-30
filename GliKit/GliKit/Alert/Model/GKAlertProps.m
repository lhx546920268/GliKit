//
//  GKAlertStyle.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAlertProps.h"
#import "NSObject+GKUtils.h"

@implementation GKAlertProps

- (instancetype)init
{
    self = [super init];
    if(self){
        self.mainColor = [UIColor whiteColor];
        self.titleFont = [UIFont boldSystemFontOfSize:17.0];
        self.titleTextColor = [UIColor blackColor];
        self.titleTextAlignment = NSTextAlignmentCenter;
        self.messageFont = [UIFont systemFontOfSize:13];
        self.messageTextColor = [UIColor blackColor];
        self.messageTextAlignment = NSTextAlignmentCenter;
        self.butttonFont = [UIFont systemFontOfSize:17];;
        self.buttonTextColor = [UIColor colorWithRed:0 green:0.4784314 blue:1.0 alpha:1.0];
        self.destructiveButtonFont = [UIFont systemFontOfSize:17];
        self.destructiveButtonTextColor = [UIColor redColor];
        self.cancelButtonFont = [UIFont boldSystemFontOfSize:17.0];
        self.cancelButtonTextColor = self.buttonTextColor;
        self.disableButtonTextColor = [UIColor grayColor];
        self.highlightedBackgroundColor = [UIColor colorWithWhite:0.6 alpha:0.3];
        self.cornerRadius = 8.0;
        self.contentInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        self.cancelButtonVerticalSpacing = 15;
        self.textInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        self.verticalSpacing = 8;
    }
    
    return self;
}

+ (instancetype)actionSheetInstance
{
    static GKAlertProps *actionSheetStyle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actionSheetStyle = [GKAlertProps new];
        actionSheetStyle.buttonHeight = 50;
    });
    
    return actionSheetStyle;
}

+ (instancetype)alertInstance
{
    static GKAlertProps *alertStyle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertStyle = [GKAlertProps new];
        alertStyle.buttonHeight = 45;
    });
    
    return alertStyle;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    GKAlertProps *style = [GKAlertProps allocWithZone:zone];
    [style gkCopyObject:self];
    
    return style;
}

@end
