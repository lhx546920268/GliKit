//
//  GKObservable.m
//  GliKit
//
//  Created by 罗海雄 on 2020/9/8.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKObservable.h"
#import <objc/runtime.h>

static void* const GKObservableContext = "com.glikit.GKObservableContext";

///回调信息
@interface GKObserverCallbackModel : NSObject

///回调
@property(nonatomic, copy) GKObserverCallback callback;

///旧值
@property(nonatomic, strong) id aOldValue;

///是否有旧值了
@property(nonatomic, readonly) BOOL hasOldValue;

///新值
@property(nonatomic, strong) id aNewValue;

+ (instancetype)modelWithCallback:(GKObserverCallback) callback;

///重置
- (void)reset;

@end

@implementation GKObserverCallbackModel

+ (instancetype)modelWithCallback:(GKObserverCallback)callback
{
    GKObserverCallbackModel *model = [GKObserverCallbackModel new];
    model.callback = callback;
    
    return model;
}

- (void)setAOldValue:(id)aOldValue
{
    if(!_hasOldValue){
        _hasOldValue = YES;
        _aOldValue = aOldValue;
    }
}

- (void)reset
{
    _hasOldValue = NO;
    self.aOldValue = nil;
    self.aNewValue = nil;
}

@end

@interface GKObservable()

///当前监听的属性
@property(nonatomic, strong) NSMutableSet<NSString*> *observingKeyPaths;

///回调
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, NSMutableDictionary<NSString*, id>*> *observerCallbacks;


@end

@implementation GKObservable

- (void)addObserver:(NSObject*)observer callback:(GKObserverCallback)callback
{
    [self addObserver:observer callback:callback forKeyPaths:@[]];
}

- (void)addObserver:(NSObject*)observer callback:(GKObserverCallback)callback forKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    NSParameterAssert(keyPath != nil);
    
    [self _addObserver:observer callback:callback forKeyPath:keyPath];
}

- (void)addObserver:(NSObject*)observer callback:(GKObserverCallback)callback forKeyPaths:(NSArray<NSString *> *)keyPaths
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    
    if(keyPaths.count > 0){
        for(NSString *keyPath in keyPaths){
            [self _addObserver:observer callback:callback forKeyPath:keyPath];
        }
    }else{
        [self addObserver:observer callback:callback forClaass:self.class];
    }
}

- (void)addObserver:(NSObject *)observer manualCallback:(GKObserverCallback)callback forKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    NSParameterAssert(keyPath != nil);
    
    [self _addObserver:observer callback:[GKObserverCallbackModel modelWithCallback:callback] forKeyPath:keyPath];
}

- (void)removeObserver:(NSObject*)observer
{
    NSParameterAssert(observer != nil);
    
    [_observerCallbacks removeObjectForKey:@(observer.hash)];
}

- (void)removeObserver:(NSObject*)observer forOneKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(keyPath != nil);
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = _observerCallbacks[key];
    [dic removeObjectForKey:keyPath];
    
    if(dic.count == 0){
        [_observerCallbacks removeObjectForKey:key];
    }
}

- (void)removeObserver:(NSObject*)observer forKeyPaths:(NSArray<NSString *> *)keyPaths
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(keyPaths != nil);
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = _observerCallbacks[key];
    for(NSString *keyPath in keyPaths){
        [dic removeObjectForKey:keyPath];
    }
    
    if(dic.count == 0){
        [_observerCallbacks removeObjectForKey:key];
    }
}

- (void)flushManualCallbackForObserver:(NSObject *)observer
{
    NSMutableDictionary *dic = _observerCallbacks[@(observer.hash)];
    for(id key in dic){
        GKObserverCallbackModel *model = dic[key];
        if([model isKindOfClass:GKObserverCallbackModel.class] && model.hasOldValue){
            model.callback(key, model.aNewValue, model.aOldValue);
            [model reset];
        }
    }
}

// MARK: - KVO

- (NSMutableSet<NSString *> *)observingKeyPaths
{
    if(!_observingKeyPaths){
        _observingKeyPaths = [NSMutableSet new];
    }
    
    return _observingKeyPaths;
}

- (NSMutableDictionary<NSNumber *,NSMutableDictionary<NSString *,GKObserverCallback> *> *)observerCallbacks
{
    if(!_observerCallbacks){
        _observerCallbacks = [NSMutableDictionary new];
    }
    
    return _observerCallbacks;
}

- (void)addObserver:(NSObject*) observer callback:(GKObserverCallback) callback forClaass:(Class) cls
{
    if(cls == [GKObservable class]){
        return;
    }
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        BOOL enable = YES;
        if(!self.shouldObserveReadonly){
            //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
            NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            NSArray *attrs = [attr componentsSeparatedByString:@","];
            
            //判断是否是只读属性
            if(attrs.count > 0 && [attrs containsObject:@"R"]){
                enable = false;
            }
        }
        if(enable){
            [self _addObserver:observer callback:callback forKeyPath:name];
        }
    }
    
    if(properties != NULL){
        free(properties);
    }
    
    //递归获取父类的属性
    [self addObserver:observer callback:callback forClaass:[cls superclass]];
}

- (void)_addObserver:(NSObject*)observer callback:(id)callback forKeyPath:(NSString *)keyPath
{
    if(![self.observingKeyPaths containsObject:keyPath]){
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:GKObservableContext];
        [self.observingKeyPaths addObject:keyPath];
    }
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = self.observerCallbacks[key];
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        self.observerCallbacks[key] = dic;
    }
    
    dic[keyPath] = callback;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(context == GKObservableContext){
        for(id key in _observerCallbacks){
            id value = _observerCallbacks[key][keyPath];
            if([value isKindOfClass:GKObserverCallbackModel.class]){
                GKObserverCallbackModel *model = value;
                model.aOldValue = change[NSKeyValueChangeOldKey];
                model.aNewValue = change[NSKeyValueChangeNewKey];
            }else{
                GKObserverCallback callback = value;
                !callback ?: callback(keyPath, change[NSKeyValueChangeNewKey], change[NSKeyValueChangeOldKey]);
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    for(NSString *keyPath in _observingKeyPaths){
        [self removeObserver:self forKeyPath:keyPath context:GKObservableContext];
    }
}

@end
