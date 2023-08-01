//
//  GKDDataBase.h
//  GliKitDemo
//
//  Created by xiaozhai on 2023/7/17.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDataBase.h"
#import <WCDBObjc/WCTTableCoding.h>
#import <WCDBObjc/WCTMacro.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDChatHistory : NSObject<WCTTableCoding>

@property(nonatomic, assign) NSInteger historyId;

///
@property(nonatomic, copy) NSString *sessionId;

///
@property(nonatomic, copy) NSString *receiverId;

///
@property(nonatomic, copy) NSString *type;

///
@property(nonatomic, copy) NSString *content;

///
@property(nonatomic, copy) NSString *uuid;

///
@property(nonatomic, assign) NSInteger time;

///
@property(nonatomic, assign) NSInteger status;

WCDB_PROPERTY(historyId)
WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(receiverId)
WCDB_PROPERTY(type)
WCDB_PROPERTY(content)
WCDB_PROPERTY(uuid)
WCDB_PROPERTY(time)
WCDB_PROPERTY(status)

@end

@interface GKDDataBase : NSObject

- (BOOL)insertHistory:(GKDChatHistory*) history;

@end

NS_ASSUME_NONNULL_END
