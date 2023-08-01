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
#import <WCDBObjc/WCDBObjc.h>

NSString* const TModuleFTS3 = [NSString stringWithUTF8String:"xx"];
NSArray *const array = @[@"", @""];

@implementation GKDChatHistory

WCDB_IMPLEMENTATION(GKDChatHistory)

WCDB_SYNTHESIZE_COLUMN(historyId, "id")
WCDB_SYNTHESIZE_COLUMN(sessionId, "session_id")
WCDB_SYNTHESIZE_COLUMN(receiverId, "to_user_id")
WCDB_SYNTHESIZE_COLUMN(type, "message_type")
WCDB_SYNTHESIZE(content)
WCDB_SYNTHESIZE(uuid)
WCDB_SYNTHESIZE_COLUMN(time, "send_time")
WCDB_SYNTHESIZE_COLUMN(status, "send_status")

WCDB_PRIMARY_AUTO_INCREMENT(historyId)
WCDB_INDEX("_session_id_index", sessionId)
WCDB_INDEX("_to_user_id_id_index", receiverId)
WCDB_INDEX("_send_time_index", time)
WCDB_INDEX("_send_status_index", status)

@end

static NSString *const GKDTableName = @"chat_history";

@interface SampleFTS : NSObject<WCTTableCoding>
@property(nonatomic, assign) int identifier;
@property(nonatomic, strong) NSString* content;
@property(nonatomic, strong) NSString* summary;
WCDB_PROPERTY(identifier)
WCDB_PROPERTY(content);
WCDB_PROPERTY(summary)
@end

@implementation SampleFTS

WCDB_IMPLEMENTATION(SampleFTS)

WCDB_SYNTHESIZE(identifier)
WCDB_SYNTHESIZE(content)
WCDB_SYNTHESIZE(summary)

WCDB_UNINDEXED(identifier) //设置identifier列不建立fts索引
WCDB_VIRTUAL_TABLE_MODULE(WCTModuleFTS5) //设置fts版本
WCDB_VIRTUAL_TABLE_TOKENIZE(WCTTokenizerVerbatim) //设置分词器

@end

@interface GKDDataBase ()

///GKDDataBase
@property(nonatomic, strong) WCTDatabase *db;

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
    
    return [sqliteDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_sqlite.db", GKAppUtils.appName]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [self sqlitePath];
        NSLog(@"%@", path);
        WCTDatabase *dataBase = [[WCTDatabase alloc] initWithPath:path];
        [dataBase traceError:^(WCTError * _Nonnull error) {
            NSLog(@"数据库出错了");
            NSLog(@"%@", error.message);
        }];
        [dataBase addTokenizer:WCTTokenizerVerbatim];
        
        BOOL result = [dataBase createTable:GKDTableName withClass:GKDChatHistory.class];
        if (!result) {
            NSLog(@"创建表失败 %@", dataBase.error);
        }
        [dataBase createVirtualTable:@"sampleVirtualTable" withClass:SampleFTS.class];

//        WCDB::StatementCreateIndex index = WCDB::StatementCreateIndex();
//        [dataBase execute:index.createIndex(WCDB::StringView("index_session_id")).ifNotExists().table(GKDTableName)];
        self.db = dataBase;
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
//    history.isAutoIncrement = YES;
//    BOOL result = [self.db insertObject:history intoTable:GKDTableName];
//    if (!result) {
//        NSLog(@"插入失败 %@", self.db.error);
//    }
//
//    SampleFTS* english = [[SampleFTS alloc] init];
//    english.identifier = 1;
//    english.content = @"WCDB is a cross-platform database framework developed by WeChat.";
//    english.summary = @"WCDB is an efficient, complete, easy-to-use mobile database framework used in the WeChat application. It can be a replacement for Core Data, SQLite & FMDB.";
//
//    SampleFTS* chinese = [[SampleFTS alloc] init];
//    chinese.identifier = 2;
//    chinese.content = @"WCDB 是微信开发的跨平台数据库框架";
//    chinese.summary = @"WCDB 是微信中使用的高效、完整、易用的移动数据库框架。它可以作为 CoreData、SQLite 和 FMDB 的替代。";
//
//    [self.db insertObjects:@[english, chinese] intoTable:@"sampleVirtualTable"];
//        return result;
//    WCDB::Column tableColumn = WCDB::Column("sampleVirtualTable");
//
    NSArray<SampleFTS*>* objects = [self.db getObjectsOfClass:SampleFTS.class fromTable:@"sampleVirtualTable" where:SampleFTS.content.match(@"Core")];

    return YES;

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

- (void)dealloc
{
    [self.db traceError:nil];
    [self.db close:^{
        NSLog(@"关闭数据库");
    }];
}

@end
