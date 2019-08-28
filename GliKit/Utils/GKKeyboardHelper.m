//
//  GKKeyboardHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKKeyboardHelper.h"

@implementation GKKeyboardHelper

+ (instancetype)sharedInstance
{
    static GKKeyboardHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        helper = [GKKeyboardHelper new];
    });
    
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//MARK: 通知

///键盘显示
- (void)keyboardWillShow:(NSNotification*) notification
{
    _keyboardShowed = YES;
}

///键盘隐藏
- (void)keyboardWillHide:(NSNotification*) notification
{
    _keyboardShowed = NO;
}

@end
