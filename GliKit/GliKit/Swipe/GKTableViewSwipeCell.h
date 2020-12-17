//
//  GKTableViewSwipeCell.h
//  GliKit
//
//  Created by 罗海雄 on 2020/12/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKSwipeCell.h"

NS_ASSUME_NONNULL_BEGIN

///可滑动显示多个按钮的cell
@interface GKTableViewSwipeCell : UITableViewCell<GKSwipeCell>

///切换按钮状态
- (void)setSwipeShow:(BOOL) show direction:(GKSwipeDirection) direction animated:(BOOL) animated;

///为了调用父类方法
- (void)willMoveToSuperview:(UIView *)newSuperview NS_REQUIRES_SUPER;
- (void)willMoveToWindow:(UIWindow *)newWindow NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
