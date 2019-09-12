//
//  GKPartialPresentationController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/5.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPartialPresentTransitionDelegate;

///部分弹窗显示
@interface GKPartialPresentationController : UIPresentationController

///关联的
@property(nonatomic, weak) GKPartialPresentTransitionDelegate *delegate;

@end

