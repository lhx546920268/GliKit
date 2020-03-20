//
//  GKBaseNavigationController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///基础导航控制视图
@interface GKBaseNavigationController : UINavigationController

///是否是手势交互返回
@property(nonatomic, readonly) BOOL isInteractivePop;

///pop 或者 push 完成回调，执行后会 变成nil
@property(nonatomic, copy) void(^transitionCompletion)(void);

@end

