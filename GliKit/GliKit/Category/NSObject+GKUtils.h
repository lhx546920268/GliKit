//
//  NSObject+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

///UIViewController扩展
@interface NSObject (GKUIViewControllerUtils)

/**
 获取当前显示的UIViewController
 */
@property(class, nonatomic, readonly) UIViewController *gkCurrentViewController;
@property(nonatomic, readonly) UIViewController *gkCurrentViewController;

/**
 获取当前显示的 UINavigationController 如果是部分present出来的，则忽略
 */
@property(class, nonatomic, readonly, nullable) UINavigationController *gkCurrentNavigationController;
@property(nonatomic, readonly, nullable) UINavigationController *gkCurrentNavigationController;

// MARK: - push

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push

 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewController:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
 如果最后一个和要打开的viewController 相同，则替换
 
 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewControllerReplaceLastSameIfNeeded:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
 移除相同的viewController
 
 @param viewController 要push 的视图控制器
 */
+ (void)gkPushViewControllerRemoveSameIfNeeded:(UIViewController*) viewController;

/**
 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push

 @param viewController 要push 的视图控制器
 @param toReplacedViewControlelrs 要替换的
 */
+ (void)gkPushViewController:(UIViewController*) viewController toReplacedViewControlelrs:(nullable NSArray<UIViewController*> *) toReplacedViewControlelrs;

@end

NS_ASSUME_NONNULL_END
