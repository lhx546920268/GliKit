//
//  GKTaskDelegate.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKBaseTask;

///代理 私有类
@protocol GKTaskDelegate <NSObject>

@optional

///请求失败
- (void)taskDidFail:(__kindof GKBaseTask*) task;

///请求成功
- (void)taskDidSuccess:(__kindof GKBaseTask*) task;

///请求完成
- (void)taskDidComplete:(__kindof GKBaseTask*) task;

@end

NS_ASSUME_NONNULL_END
