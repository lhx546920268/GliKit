//
//  GKWeakProxy.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///弱引用代理，主要用于 会造成循环引用的地方，比如 计时器的 target
@interface GKWeakProxy : NSProxy

///target
@property(nonatomic, weak, readonly, nullable) id target;

///构造方法
- (instancetype)initWithTarget:(nullable id) target;
+ (instancetype)weakProxyWithTarget:(nullable id) target;

@end

NS_ASSUME_NONNULL_END

