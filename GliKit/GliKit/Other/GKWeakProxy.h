//
//  GKWeakProxy.h
//  GliKit
//
//  Created by 罗海雄 on 2019/9/2.
//

#import <Foundation/Foundation.h>

///弱引用代理，主要用于 会造成循环引用的地方，比如 计时器的 target
@interface GKWeakProxy : NSProxy

///target
@property(nonatomic, weak, readonly) id target;

///构造方法
- (instancetype)initWithTarget:(id) target;
+ (instancetype)weakProxyWithTarget:(id) target;

@end

