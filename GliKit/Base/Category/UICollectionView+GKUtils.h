//
//  UICollectionView+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///集合视图扩展
@interface UICollectionView (GKUtils)

///方便的注册 cell reuseIdentifierd都是类的名称

- (void)registerNib:(Class)clazz;
- (void)registerClass:(Class)cellClas;

- (void)registerHeaderClass:(Class) clazz;
- (void)registerHeaderNib:(Class) clazz;

- (void)registerFooterClass:(Class) clazz;
- (void)registerFooterNib:(Class) clazz;

@end

