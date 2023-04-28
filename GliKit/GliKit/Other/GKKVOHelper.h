//
//  GKKVOHelper.h
//  GliKit
//
//  Created by 罗海雄 on 2020/9/8.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 回调
/// @param keyPath  属性，和addObserver 中的一致
/// @param newValue 新值 值类型要拆箱
/// @param oldValue 旧值 值类型要拆箱
typedef void(^GKKVOCallback)(NSString *keyPath, id _Nullable newValue, id _Nullable oldValue);

/// kvo帮助类
@interface GKKVOHelper : NSObject

/// 是否监听只读属性 default `NO`
@property(nonatomic, assign) BOOL shouldObserveReadonly;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

///初始化 owner是被观察者
+ (instancetype)helperWithOwner:(NSObject*) owner;

/// 添加一个观察者，必须通过 .语法 设置新值才会触发回调
/// @param observer 观察者，将使用hash作为 key来保存
/// @param callback 回调
/// @param keyPath 要监听的属性，如果为空，则监听所有属性
- (void)addObserver:(NSObject*) observer callback:(GKKVOCallback) callback forKeyPath:(NSString*) keyPath;
- (void)addObserver:(NSObject*) observer callback:(GKKVOCallback) callback forKeyPaths:(NSArray<NSString*>*) keyPaths;
- (void)addObserver:(NSObject*) observer callback:(GKKVOCallback) callback;

/// 需要手动调用回调 主要用于值可能发生多次改变，但只需要回调一次
- (void)addObserver:(NSObject*) observer manualCallback:(GKKVOCallback) callback forKeyPath:(NSString*) keyPath;

/// 调用未回调的
- (void)flushManualCallback;

/// 移除观察者
/// @param observer 观察者，将使用hash作为 key来保存
/// @param keyPath 监听的属性，如果为空，则移除observer对应的所有 keyPath
- (void)removeObserver:(NSObject*) observer forOneKeyPath:(NSString*) keyPath;
- (void)removeObserver:(NSObject*) observer forKeyPaths:(NSArray<NSString*>*) keyPaths;
- (void)removeObserver:(NSObject*) observer;

/// 移除所有观察者
- (void)removeAllObservers;

@end

///kvo扩展
@interface NSObject (GKKVOUtils)

///kvo帮助类 懒加载
@property(nonatomic, readonly) GKKVOHelper *kvoHelper;

///kvo帮助类 为空时不会创建
@property(nonatomic, readonly, nullable) GKKVOHelper *kvoHelperNullable;

@end

NS_ASSUME_NONNULL_END
