//
//  UIViewController+GKSafeAreaCompatible.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///安全区域兼容 iOS11
@interface UIViewController (GKSafeAreaCompatible)

///安全区域 顶部
@property (nonatomic, strong, readonly) MASViewAttribute *gk_safeAreaLayoutGuideTop;

///安全区域 底部
@property (nonatomic, strong, readonly) MASViewAttribute *gk_safeAreaLayoutGuideBottom;

///安全区域 左边
@property (nonatomic, strong, readonly) MASViewAttribute *gk_safeAreaLayoutGuideLeft;

///安全区域 右边
@property (nonatomic, strong, readonly) MASViewAttribute *gk_safeAreaLayoutGuideRight;

@end

