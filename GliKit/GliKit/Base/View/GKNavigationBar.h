//
//  GKNavigationBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/27.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///导航栏
@interface GKNavigationBar : UIView

///阴影
@property(nonatomic, readonly) UIView *shadowView;

///背景
@property(nonatomic, readonly) UIView *backgroundView;

@end

NS_ASSUME_NONNULL_END
