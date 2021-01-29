//
//  GKCollectionConfigurableItem.h
//  GliKit
//
//  Created by 罗海雄 on 2021/1/26.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

///保存item大小的
@protocol GKItemSizeModel <NSObject>

///item大小
@property(nonatomic, assign) CGSize itemSize;

@end

///可配置的item
@protocol GKCollectionConfigurableItem <NSObject>

///对应的数据
@property(nonatomic, strong) id<GKItemSizeModel> model;

@end
