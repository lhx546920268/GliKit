//
//  UIImage+GKTheme.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//app图标
@interface UIImage (GKTheme)

///导航栏返回图标
@property(class, nonatomic, strong) UIImage *gkNavigationBarBackIcon;

///生成图片的scale
@property(class, nonatomic, assign) CGFloat gkImageScale;

@end

NS_ASSUME_NONNULL_END

