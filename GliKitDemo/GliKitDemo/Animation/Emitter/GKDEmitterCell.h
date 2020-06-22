//
//  GKDEmitterCell.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/6/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDEmitterCell : NSObject

@property(nonatomic, assign) int currentFrame;

///xx
@property(nonatomic, assign) NSTimeInterval duration;

///x
@property(nonatomic, assign) CGFloat y;


///x
@property(nonatomic, assign) CGFloat x;

///刷新
- (void)refreshWithHeight:(CGFloat) height;

@end

NS_ASSUME_NONNULL_END
