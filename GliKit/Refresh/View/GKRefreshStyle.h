//
//  GKRefreshStyle.h
//  GliKit
//
//  Created by luohaixiong on 2018/7/20.
//  Copyright © 2018年 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 刷新样式
 */
@interface GKRefreshStyle : NSObject

///下拉刷新
@property(nonatomic, strong, nonnull) Class refreshClass;

///加载更多
@property(nonatomic, strong, nonnull) Class loadMoreClass;

///单例
+ (nonnull instancetype)sharedInstance;

@end
