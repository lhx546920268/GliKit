//
//  UIScreen+GKUtils.h
//  Zegobird
//
//  Created by 唐建平 on 2019/3/20.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///屏幕扩展
@interface UIScreen (GKUtils)

///获取屏幕宽度
@property (class, nonatomic, readonly) CGFloat gk_screenWidth;

///获取屏幕高度
@property (class, nonatomic, readonly) CGFloat gk_screenHeight;

///获取屏幕大小
@property (class, nonatomic, readonly) CGSize gk_screenSize;

@end

