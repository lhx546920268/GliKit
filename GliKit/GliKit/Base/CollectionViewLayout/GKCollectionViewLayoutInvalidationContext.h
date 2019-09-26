//
//  GKCollectionViewLayoutInvalidationContext.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/23.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

///更新invalid item 用来提升性能 吸顶情况只有 header需要更新
@interface GKCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

///当前需要更新的
@property(nonatomic, strong, nullable) NSDictionary<NSString*, NSArray<NSIndexPath*> *> *invalidSupplementaryIndexPaths;

@end

