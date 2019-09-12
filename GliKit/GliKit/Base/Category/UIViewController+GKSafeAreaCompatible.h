//
//  UIViewController+GKSafeAreaCompatible.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASViewAttribute;

///安全区域兼容 iOS11
@interface UIViewController (GKSafeAreaCompatible)

///安全区域 顶部
@property (nonatomic, strong, readonly) MASViewAttribute *gkSafeAreaLayoutGuideTop;

///安全区域 底部
@property (nonatomic, strong, readonly) MASViewAttribute *gkSafeAreaLayoutGuideBottom;

///安全区域 左边
@property (nonatomic, strong, readonly) MASViewAttribute *gkSafeAreaLayoutGuideLeft;

///安全区域 右边
@property (nonatomic, strong, readonly) MASViewAttribute *gkSafeAreaLayoutGuideRight;

@end

