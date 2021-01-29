//
//  GKTableConfigurableItem.h
//  GliKit
//
//  Created by 罗海雄 on 2021/1/26.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

///保存行高的
@protocol GKRowHeightModel <NSObject>

///行高
@property(nonatomic, assign) CGFloat rowHeight;

@end

///可配置的item
@protocol GKTableConfigurableItem <NSObject>

///对应的数据
@property(nonatomic, strong) id<GKRowHeightModel> model;

@end
