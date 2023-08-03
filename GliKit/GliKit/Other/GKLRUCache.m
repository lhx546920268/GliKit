//
//  GKLRUCache.m
//  GliKit
//
//  Created by xiaozhai on 2023/8/2.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKLRUCache.h"

///链表节点
@interface GKLRUCacheLinkedNode : NSObject

///
@property(nonatomic, strong) GKLRUCacheLinkedNode *prev;
@property(nonatomic, strong) GKLRUCacheLinkedNode *next;

///
@property(nonatomic, copy) id<NSCopying> key;

///
@property(nonatomic, strong) id object;

@end

@implementation GKLRUCacheLinkedNode

+ (instancetype)nodeWithKey:(id<NSCopying>) key object:(id) object
{
    GKLRUCacheLinkedNode *node = [GKLRUCacheLinkedNode new];
    node.key = key;
    node.object = object;
    
    return node;
}

@end

@interface GKLRUCache ()

///容器
@property(nonatomic, strong) NSMutableDictionary *container;

///链表头尾
@property(nonatomic, strong) GKLRUCacheLinkedNode *head;
@property(nonatomic, strong) GKLRUCacheLinkedNode *tail;

@end

@implementation GKLRUCache

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        NSAssert(capacity > 0, @"GKLRUCache capacity must greater than 0");
        _capacity = capacity;
        _container = [NSMutableDictionary dictionaryWithCapacity:capacity];
    }
    return self;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    if (!key) return;
    if (!object) [_container removeObjectForKey:key];
    
    GKLRUCacheLinkedNode *node = [GKLRUCacheLinkedNode nodeWithKey:key object:object];
    if (!self.head) self.head = node;
    node.prev = self.tail;
    self.tail.next = node;
    self.tail = node;
    
    [_container setObject:node forKey:key];
    if (_container.count > self.capacity) {
        GKLRUCacheLinkedNode *next = self.head.next;
        [_container removeObjectForKey:self.head.key];
        self.head = next;
        self.head.prev = nil;
        if (self.tail == self.head) self.tail = nil;
    }
}

- (id)removeObjectForKey:(id<NSCopying>)key
{
    if (!key) return nil;
    GKLRUCacheLinkedNode *node = [_container objectForKey:key];
    [_container removeObjectForKey:key];
    return node.object;
}

- (id)objectForKey:(id<NSCopying>)key
{
    GKLRUCacheLinkedNode *node = [_container objectForKey:key];
    return node.object;
}

@end
