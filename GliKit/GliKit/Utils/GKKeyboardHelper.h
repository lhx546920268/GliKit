//
//  GKKeyboardHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
