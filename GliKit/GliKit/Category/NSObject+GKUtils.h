//
//  NSObject+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define GKConvenientCoder \
- (instancetype)initWithCoder:(NSCoder *)aDecoder{ \
    self = [super init]; \
    if(self){ \
        [self gkInitWithCoder:aDecoder]; \
    } \
    return self; \
} \
- (void)encodeWithCoder:(NSCoder *)aCoder{ \
    [self gkEncodeWithCoder:aCoder]; \
} \

#define GKConvenientSecureCoder \
GKConvenientCoder \
+ (BOOL)supportsSecureCoding \
{ \
    return YES; \
} \

///扩展
@interface NSObject (GKUtils)

/**
 获取当前类的所有属性名称
 */
@property(nonatomic, readonly) NSArray<NSString*> *gkPropertyNames;

/**
 获取 class name
 */
@property(class, nonatomic, readonly) NSString *gkNameOfClass;
@property(nonatomic, readonly) NSString *gkNameOfClass;

// MARK: - 方法交换

/**
 交换实例方法实现
 
 @param selector1 方法1
 @param prefix 前缀，方法2 = 前缀 + 方法1名字
 */
+ (void)gkExchangeImplementations:(SEL) selector1 prefix:(NSString*) prefix;

/**
 交换实例方法实现
 
 @param selector1 方法1
 @param selector2 方法2
 */
+ (void)gkExchangeImplementations:(SEL) selector1 selector2:(SEL) selector2;

// MARK: - coder

/**
 自动化归档，在encodeWithCoder 中调用，子类不需要重写encodeWithCoder
 
 @param coder encodeWithCoder 中的coder
 */
- (void)gkEncodeWithCoder:(NSCoder*) coder;

/**
 自动化解档，在initWithCoder 中调用，子类不需要重写initWithCoder
 
 @param decoder initWithCoder 中的decoder
 */
- (void)gkInitWithCoder:(NSCoder*) decoder;

// MARK: - copy

/**
 拷贝某个对象

 @param object 这个对象必须是当前类的或者其子类
 */
- (void)gkCopyObject:(NSObject*) object;

@end

NS_ASSUME_NONNULL_END
