//
//  GKWeakProxy.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/2.
//

#import "GKWeakProxy.h"

@implementation GKWeakProxy

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

+ (instancetype)weakProxyWithTarget:(id)target
{
    return [[GKWeakProxy alloc] initWithTarget:target];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation setTarget:_target];
    [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_target methodSignatureForSelector:sel];
}

- (BOOL)isProxy
{
    return YES;
}

@end
