//
//  GKDPhotosViewController.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <GKCollectionViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDPhotosViewController : GKCollectionViewController

@property(nonatomic, copy) NSString *photoName;
@property(nonatomic, copy) void(^selectHandler)(NSString *title);

@end

NS_ASSUME_NONNULL_END
