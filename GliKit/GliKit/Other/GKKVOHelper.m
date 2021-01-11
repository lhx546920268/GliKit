//
//  GKKVOHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2020/9/8.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKKVOHelper.h"
#import <objc/runtime.h>

static void* const GKOKVOContext = "com.glikit.GKOKVOContext";

///回调信息
@interface GKKVOCallbackModel : NSObject

///回调
@property(nonatomic, copy) GKKVOCallback callback;

///旧值
@property(nonatomic, strong) id aOldValue;

///是否有旧值了
@property(nonatomic, readonly) BOOL hasOldValue;

///新值
@property(nonatomic, strong) id aNewValue;

+ (instancetype)modelWithCallback:(GKKVOCallback) callback;

///重置
- (void)reset;

@end

@implementation GKKVOCallbackModel

+ (instancetype)modelWithCallback:(GKKVOCallback)callback
{
    GKKVOCallbackModel *model = [GKKVOCallbackModel new];
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

@interface GKKVOHelper()

///当前监听的属性
@property(nonatomic, strong) NSMutableSet<NSString*> *observingKeyPaths;

///回调
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, NSMutableDictionary<NSString*, id>*> *callbacks;

///被观察者
@property(nonatomic, weak) NSObject *owner;

@end

@implementation GKKVOHelper

+ (instancetype)helperWithOwner:(NSObject *)owner
{
    GKKVOHelper *helper = [GKKVOHelper new];
    helper.owner = owner;
    return helper;
}

- (void)addObserver:(NSObject*)observer callback:(GKKVOCallback)callback
{
    [self addObserver:observer callback:callback forKeyPaths:@[]];
}

- (void)addObserver:(NSObject*)observer callback:(GKKVOCallback)callback forKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    NSParameterAssert(keyPath != nil);
    
    [self _addObserver:observer callback:callback forKeyPath:keyPath];
}

- (void)addObserver:(NSObject*)observer callback:(GKKVOCallback)callback forKeyPaths:(NSArray<NSString *> *)keyPaths
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    
    if(keyPaths.count > 0){
        for(NSString *keyPath in keyPaths){
            [self _addObserver:observer callback:callback forKeyPath:keyPath];
        }
    }else{
        [self addObserver:observer callback:callback forClaass:self.owner.class];
    }
}

- (void)addObserver:(NSObject *)observer manualCallback:(GKKVOCallback)callback forKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(callback != nil);
    NSParameterAssert(keyPath != nil);
    
    [self _addObserver:observer callback:[GKKVOCallbackModel modelWithCallback:callback] forKeyPath:keyPath];
}

- (void)flushManualCallbackForObserver:(NSObject *)observer
{
    NSMutableDictionary *dic = _callbacks[@(observer.hash)];
    for(id key in dic){
        GKKVOCallbackModel *model = dic[key];
        if([model isKindOfClass:GKKVOCallbackModel.class] && model.hasOldValue){
            model.callback(key, model.aNewValue, model.aOldValue);
            [model reset];
        }
    }
}

- (void)removeObserver:(NSObject*)observer
{
    NSParameterAssert(observer != nil);
    
    [_callbacks removeObjectForKey:@(observer.hash)];
}

- (void)removeObserver:(NSObject*)observer forOneKeyPath:(NSString *)keyPath
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(keyPath != nil);
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = _callbacks[key];
    [dic removeObjectForKey:keyPath];
    
    if(dic.count == 0){
        [_callbacks removeObjectForKey:key];
    }
}

- (void)removeObserver:(NSObject*)observer forKeyPaths:(NSArray<NSString *> *)keyPaths
{
    NSParameterAssert(observer != nil);
    NSParameterAssert(keyPaths != nil);
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = _callbacks[key];
    for(NSString *keyPath in keyPaths){
        [dic removeObjectForKey:keyPath];
    }
    
    if(dic.count == 0){
        [_callbacks removeObjectForKey:key];
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

- (NSMutableDictionary<NSNumber *,NSMutableDictionary<NSString *,id> *> *)callbacks
{
    if(!_callbacks){
        _callbacks = [NSMutableDictionary new];
    }
    
    return _callbacks;
}

- (void)addObserver:(NSObject*) observer callback:(GKKVOCallback) callback forClaass:(Class) cls
{
    if(cls == nil || cls == [NSObject class]){
        return;
    }
    
    //获取当前类的所有属性，该方法无法获取父类或者子类的属性
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for(int i = 0;i < count;i ++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        BOOL enabled = YES;
        if(!self.shouldObserveReadonly){
            //类型地址 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
            NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            NSArray *attrs = [attr componentsSeparatedByString:@","];
            
            //判断是否是只读属性
            if(attrs.count > 0 && [attrs containsObject:@"R"]){
                enabled = false;
            }
        }
        if(enabled){
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
        [self.owner addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:GKOKVOContext];
        [self.observingKeyPaths addObject:keyPath];
    }
    
    id key = @(observer.hash);
    NSMutableDictionary *dic = self.callbacks[key];
    if(!dic){
        dic = [NSMutableDictionary dictionary];
        self.callbacks[key] = dic;
    }
    
    dic[keyPath] = callback;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(context == GKOKVOContext){
        for(id key in _callbacks){
            id value = _callbacks[key][keyPath];
            if([value isKindOfClass:GKKVOCallbackModel.class]){
                GKKVOCallbackModel *model = value;
                model.aOldValue = change[NSKeyValueChangeOldKey];
                model.aNewValue = change[NSKeyValueChangeNewKey];
            }else{
                GKKVOCallback callback = value;
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
        [self.owner removeObserver:self forKeyPath:keyPath context:GKOKVOContext];
    }
}

@end


@implementation NSObject(GKKVOUtils)

- (GKKVOHelper *)kvoHelper
{
    GKKVOHelper *helper = objc_getAssociatedObject(self, _cmd);
    if(!helper){
        helper = [GKKVOHelper helperWithOwner:self];
        objc_setAssociatedObject(self, _cmd, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

@end
