//
//  UIScreen+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///屏幕扩展
@interface UIScreen (GKUtils)

///获取屏幕宽度
@property (class, nonatomic, readonly) CGFloat gkWidth;

///获取屏幕高度
@property (class, nonatomic, readonly) CGFloat gkHeight;

///获取屏幕大小
@property (class, nonatomic, readonly) CGSize gkSize;

@end

