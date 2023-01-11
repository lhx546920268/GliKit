//
//  GKPhotosCache.h
//  GliKit
//
//  Created by 罗海雄 on 2023/1/10.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKPhotosCollection, GKPhotosOptions;

///加载相册信息完成回调
typedef void(^CALoadPhotosCompletionHandler)(NSArray<GKPhotosCollection*> * _Nullable collections);

///相册缓存
@interface GKPhotosCache : NSObject

///单例
@property(class, nonatomic, readonly) GKPhotosCache *sharedCache;

///收到内存警告是否清除缓存 default `YES`
@property(nonatomic, assign) BOOL clearWhenLowMemory;

///进入后台是否清除缓存 default `YES`
@property(nonatomic, assign) BOOL clearWhenEnterBackground;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

///加载相册信息
- (void)loadPhotosWithOptions:(GKPhotosOptions *)options completionHandler:(CALoadPhotosCompletionHandler)completionHandler;

///清除缓存
- (void)clear;

@end

NS_ASSUME_NONNULL_END
