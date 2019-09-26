//
//  GKHttpTaskDelegate.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKHttpTask;

///代理
@protocol GKHttpTaskDelegate <NSObject>

@optional

///请求失败
- (void)taskDidFail:(__kindof GKHttpTask*) task;

///请求成功
- (void)taskDidSuccess:(__kindof GKHttpTask*) task;

///请求完成
- (void)taskDidComplete:(__kindof GKHttpTask*) task;

@end

NS_ASSUME_NONNULL_END
