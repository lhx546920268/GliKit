//
// Created by sanhuazhang on 2019/05/02
//

/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Assertion.hpp"
#import "Console.hpp"
#import "Core.hpp"
#import "DBOperationNotifier.hpp"
#import "WCTDatabase+Monitor.h"
#import "WCTDatabase+Private.h"
#import "WCTError+Private.h"
#import "WCTFoundation.h"

namespace WCDB {

void Core::print(const UnsafeStringView& message)
{
#if WCDB_DEBUG
    NSLog(@"%s", message.data());
#endif
}

}

@implementation WCTDatabase (Monitor)

+ (void)globalTraceError:(WCTErrorTraceBlock)block
{
    if (block != nil) {
        WCDB::Core::shared().setNotificationWhenErrorTraced([block](const WCDB::Error& error) {
            WCTError* nsError = [[WCTError alloc] initWithError:error];
            block(nsError);
        });
    } else {
        WCDB::Core::shared().setNotificationWhenErrorTraced(nullptr);
    }
}

- (void)traceError:(nullable WCDB_ESCAPE WCTErrorTraceBlock)block
{
    if (block != nil) {
        WCDB::Core::shared().setNotificationWhenErrorTraced(self.path, [block](const WCDB::Error& error) {
            WCTError* nsError = [[WCTError alloc] initWithError:error];
            block(nsError);
        });
    } else {
        WCDB::Core::shared().setNotificationWhenErrorTraced(self.path, nullptr);
    }
}

+ (void)globalTracePerformance:(WCTPerformanceTraceBlock)trace
{
    WCDB::InnerHandle::PerformanceNotification callback = nullptr;
    if (trace != nil) {
        callback = [trace](const WCDB::UnsafeStringView& path, const WCDB::UnsafeStringView& sql, double cost, const void* handle) {
            trace([NSString stringWithUTF8String:path.data()], (uint64_t) handle, [NSString stringWithUTF8String:sql.data()], cost);
        };
    }
    WCDB::Core::shared().setNotificationWhenPerformanceGlobalTraced(callback);
}

+ (void)globalTraceSQL:(WCTSQLTraceBlock)trace
{
    WCDB::InnerHandle::SQLNotification callback = nullptr;
    if (trace != nil) {
        callback = [trace](const WCDB::UnsafeStringView& path, const WCDB::UnsafeStringView& sql, const void* handle) {
            trace([NSString stringWithUTF8String:path.data()], (uint64_t) handle, [NSString stringWithView:sql]);
        };
    }
    WCDB::Core::shared().setNotificationForSQLGLobalTraced(callback);
}

- (void)tracePerformance:(WCTPerformanceTraceBlock)trace
{
    if (trace != nil) {
        WCDB::InnerHandle::PerformanceNotification callback = [trace](const WCDB::UnsafeStringView& path, const WCDB::UnsafeStringView& sql, double cost, const void* handle) {
            trace([NSString stringWithUTF8String:path.data()], (uint64_t) handle, [NSString stringWithUTF8String:sql.data()], cost);
        };
        _database->setConfig(WCDB::PerformanceTraceConfigName,
                             std::static_pointer_cast<WCDB::Config>(std::make_shared<WCDB::PerformanceTraceConfig>(callback)),
                             WCDB::Configs::Priority::Highest);
    } else {
        _database->removeConfig(WCDB::PerformanceTraceConfigName);
    }
}

- (void)traceSQL:(WCTSQLTraceBlock)trace
{
    if (trace != nil) {
        WCDB::InnerHandle::SQLNotification callback = [trace](const WCDB::UnsafeStringView& path, const WCDB::UnsafeStringView& sql, const void* handle) {
            trace([NSString stringWithUTF8String:path.data()], (uint64_t) handle, [NSString stringWithView:sql]);
        };
        _database->setConfig(WCDB::SQLTraceConfigName,
                             std::static_pointer_cast<WCDB::Config>(std::make_shared<WCDB::SQLTraceConfig>(callback)),
                             WCDB::Configs::Priority::Highest);
    } else {
        _database->removeConfig(WCDB::SQLTraceConfigName);
    }
}

+ (void)globalTraceDatabaseOperation:(nullable WCDB_ESCAPE WCTDatabaseOperationTraceBlock)trace
{
    if (trace != nil) {
        WCDB::DBOperationNotifier::shared().setNotification([=](WCDB::InnerDatabase* innerDatabase, WCDB::DBOperationNotifier::Operation operation) {
            WCTDatabase* database = [[WCTDatabase alloc] initWithUnsafeDatabase:innerDatabase];
            trace(database, (WCTDatabaseOperation) operation);
        });
    } else {
        WCDB::DBOperationNotifier::shared().setNotification(nil);
    }
}

@end
