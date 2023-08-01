//
//  GKDialogInteractiveDismisHelper.h
//  GliKit
//
//  Created by xiaozhai on 2023/8/1.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///滑动消失帮助类
@interface GKDialogInteractiveDismisHelper : NSObject

///
@property(nonatomic, weak, readonly, nullable) UIViewController *viewController;

///
- (instancetype)initWithViewController:(UIViewController*) viewController;

@end

NS_ASSUME_NONNULL_END
