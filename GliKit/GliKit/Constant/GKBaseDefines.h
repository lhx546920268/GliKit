//
//  GKBaseDefines.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#ifndef GKBaseDefines_h
#define GKBaseDefines_h

//发布(release)的项目不打印日志
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

//拼接2个，把2个变量名称拼接成一个变量名称，比如 GKConcat(self, Weak)，就变成selfWeak
#ifndef GKConcat
#define GKConcat(a, b) a##b
#endif

//weak 使用 WeakObj(self);  selfWeak
#ifndef WeakObj
#define WeakObj(o) __weak typeof(o) GKConcat(o, Weak) = o;
#endif

//strong 使用
#ifndef StrongObj
#define StrongObj(o) __strong typeof(o) o = GKConcat(o, Weak);
#endif

//未实现某个方法
#ifndef GKThrowNotImplException
#define GKThrowNotImplException @throw [[NSException alloc] initWithName:@"GKNotImplException" reason:[NSString stringWithFormat:@"%@ 必须实现 %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd)] userInfo:nil];
#endif

//延迟执行，秒
#ifndef dispatch_main_after
#define dispatch_main_after(s, block)\
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(s * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
#endif

#import <Masonry/Masonry.h>

#endif /* GKBaseDefines_h */
