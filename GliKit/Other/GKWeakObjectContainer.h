//
//  GKWeakObjectContainer.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>

///主要用于类目中设置 weak的属性， 因为 objc_setAssociatedObject 是没有weak的
@interface GKWeakObjectContainer : NSObject

///需要weak引用的对象
@property(nonatomic,weak) id weakObject;

+ (instancetype)containerWithObject:(id) object;

@end
