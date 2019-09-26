//
//  GKSkeletonSubLayer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///骨架子图层
@interface GKSkeletonSubLayer : CALayer

///复制属性
- (void)copyPropertiesFromLayer:(CALayer*) layer;

@end

NS_ASSUME_NONNULL_END

