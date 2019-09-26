//
//  GKBaseDefines.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#ifndef GKBaseDefines_h
#define GKBaseDefines_h

// 定义这个常量，就可以让Masonry帮我们自动把基础数据类型的数据，自动装箱为对象类型。
#define MAS_SHORTHAND_GLOBALS

//发布(release)的项目不打印日志
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

//weak 使用 WeakObj(self);  selfWeak
#define WeakObj(o) __weak typeof(o) o##Weak = o;

#import <Masonry.h>

#endif /* GKBaseDefines_h */
