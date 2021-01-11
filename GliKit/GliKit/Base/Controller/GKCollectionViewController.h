//
//  GKCollectionViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKScrollViewController.h"
#import "UICollectionView+GKEmptyView.h"
#import "UICollectionView+GKCellSize.h"

NS_ASSUME_NONNULL_BEGIN

///基础集合视图控制器
@interface GKCollectionViewController : GKScrollViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

///信息列表
@property(nonatomic, readonly) UICollectionView *collectionView;

///布局方式 default `UICollectionViewFlowLayout`
@property(nonatomic, strong) UICollectionViewLayout *layout;

///默认流布局方式，当没有设置layout时会使用这个
@property(nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

///使用一个layout初始化
- (instancetype)initWithFlowLayout:(nullable UICollectionViewLayout*) layout;

///注册cell
- (void)registerNib:(Class) clazz;
- (void)registerClass:(Class) clazz;

- (void)registerHeaderClass:(Class) clazz;
- (void)registerHeaderNib:(Class) clazz;

- (void)registerFooterClass:(Class) clazz;
- (void)registerFooterNib:(Class) clazz;

///系统的需要添加 __kindof 否则代码不会提示
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

