//
//  GKDataBase.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDatabaseQueue;

///数据库
@interface GKDataBase : NSObject

///数据库队列
@property(nonatomic, readonly) FMDatabaseQueue *dbQueue;

///数据库地址
@property(nonatomic, readonly) NSString *sqlitePath;

///数据库单例
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
