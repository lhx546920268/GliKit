//
//  GKLock.m
//  GliKit
//
//  Created by 罗海雄 on 2020/12/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKLock.h"

@interface GKLock()

///锁
@property(nonatomic, strong) dispatch_semaphore_t semaphoreLock;

@end

@implementation GKLock

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.semaphoreLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)lock
{
    dispatch_semaphore_wait(self.semaphoreLock, DISPATCH_TIME_FOREVER);
}

- (void)unlock
{
    dispatch_semaphore_signal(self.semaphoreLock);
}

@end
