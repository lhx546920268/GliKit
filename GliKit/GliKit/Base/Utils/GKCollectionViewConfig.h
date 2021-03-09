//
//  GKCollectionViewConfig.h
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKScrollViewConfig.h"
#import "GKCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKCollectionViewConfig : GKScrollViewConfig<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

///绑定的viewController
@property(nonatomic, weak, nullable, readonly) __kindof GKCollectionViewController *viewController;

///关联的collectionView
@property(nonatomic, nullable, readonly) UICollectionView *collectionView;

///注册cell
- (void)registerNib:(Class) clazz;
- (void)registerClass:(Class) clazz;

- (void)registerHeaderClass:(Class) clazz;
- (void)registerHeaderNib:(Class) clazz;

- (void)registerFooterClass:(Class) clazz;
- (void)registerFooterNib:(Class) clazz;

@end

NS_ASSUME_NONNULL_END
