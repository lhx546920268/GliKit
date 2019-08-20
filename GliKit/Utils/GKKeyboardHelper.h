//
//  GKKeyboardHelper.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>

///键盘帮助类
@interface GKKeyboardHelper : NSObject

///单例
+ (instancetype)sharedInstance;

///启动监听
- (void)start;

///停止监听
- (void)stop;

///当前键盘是否显示
@property(nonatomic, readonly) BOOL keyboardShowed;

@end
