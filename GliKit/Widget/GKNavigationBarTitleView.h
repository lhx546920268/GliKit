//
//  GKNavigationBarTitleView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 iOS 11.0后 导航栏的标题栏， 在ios11后 导航栏的图层结构已发生变化，使用这个可以调整标题栏大小
 titleView内部有子视图使用约束时才需要
 */
@interface GKNavigationBarTitleView : UIView

/**
 内容大小 default is 'UILayoutFittingExpandedSize'
 */
@property(nonatomic, assign) CGSize contentSize;

@end

