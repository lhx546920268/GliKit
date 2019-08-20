//
//  GKAlertAction.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKAlertAction.h"

@implementation GKAlertAction

- (instancetype)init
{
    self = [super init];
    if(self){
        self.enable = YES;
        self.spacing = 5;
    }
    
    return self;
}

+ (instancetype)alertActionWithTitle:(NSString*) title
{
    return [self alertActionWithTitle:title icon:nil];
}

+ (instancetype)alertActionWithTitle:(NSString*) title icon:(UIImage*) icon
{
    GKAlertAction *action = [[[self class] alloc] init];
    action.title = title;
    action.icon = icon;
    
    return action;
}

@end
