//
//  GKDDataBase.m
//  GliKitDemo
//
//  Created by xiaozhai on 2023/7/17.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDDataBase.h"

#import <GKFileManager.h>
#import <GKAppUtils.h>
#import <WCDBObjc/StringView.hpp>

@implementation GKDChatHistory

//WCDB_IMPLEMENTATION(GKDChatHistory)
//
//WCDB_SYNTHESIZE_COLUMN(sessionId, "session_id")
//WCDB_SYNTHESIZE_COLUMN(receiverId, "to_user_id")
//WCDB_SYNTHESIZE_COLUMN(type, "message_type")
//WCDB_SYNTHESIZE(content)
//WCDB_SYNTHESIZE(uuid)
//WCDB_SYNTHESIZE_COLUMN(time, "send_time")
//WCDB_SYNTHESIZE_COLUMN(status, "send_status")
//
//WCDB_PRIMARY_AUTO_INCREMENT(sessionId)

@end

static NSString *const GKDTableName = @"demo";

@interface GKDDataBase ()

///GKDDataBase
//@property(nonatomic, strong) WCTDatabase *db;

@end

@implementation GKDDataBase

///获取数据库地址
- (NSString*)sqlitePath
{
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *sqliteDirectory = [docDirectory stringByAppendingPathComponent:@"sqlite"];
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:sqliteDirectory isDirectory:&isDir];
    
    if(!(exist && isDir)){
        if(![fileManager createDirectoryAtPath:sqliteDirectory withIntermediateDirectories:YES attributes:nil error:nil]){
            return nil;
        }else{
            //防止iCloud备份
            [GKFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:sqliteDirectory isDirectory:YES]];
        }
    }
    
    return [sqliteDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_sqlite", GKAppUtils.appName]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [self sqlitePath];
//        WCTDatabase *dataBase = [[WCTDatabase alloc] initWithPath:path];
//        [dataBase createTable:GKDTableName withClass:GKDChatHistory.class];
//
//        WCDB::StatementCreateIndex index = WCDB::StatementCreateIndex();
//        [dataBase execute:index.createIndex(WCDB::StringView("index_session_id")).ifNotExists().table(GKDTableName)];
//        self.db = dataBase;
    }
    return self;
}

//- (void)onDataBaseOpen:(FMDatabase *)db
//{
//    //创建聊天记录表
//    if(![db executeUpdate:@"create table if not exists chat_history_list(id integer primary key autoincrement,session_id integer,to_user_id integer,message_type text,content text,uuid text,send_time integer,send_status integer)"]){
//        NSLog(@"创建聊天记录表失败");
//    }
//    [db tableExists:nil];
//    [db executeUpdate:@"CREATE INDEX if not exists `index_session_id` ON `chat_history_list`(`session_id`)"];
//}

- (BOOL)insertHistory:(GKDChatHistory*) history
{
    return YES;
//    return [self.db insertObject:history intoTable:GKDTableName];
//    __block BOOL result = NO;
//    [self.dbQueue inDatabase:^(FMDatabase *db){
//        NSString *sql = @"insert into chat_history_list(session_id,to_user_id,message_type,content,uuid,send_time,send_status) values(?,?,?,?,?,?,?)";
//        [db executeUpdate:sql,
//         @(history.sessionId.integerValue),
//         @(history.receiverId.integerValue),
//         history.type,
//         history.content,
//         history.uuid,
//         @(history.time),
//         @(history.status)];
//    }];
//
//    return result;
}

@end
