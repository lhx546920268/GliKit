//
//  GKPhotosGridViewController.h
//  IOSLibrary
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCollectionViewController.h"


@class GKPhotosOptions, GKPhotosCollection;

///相册网格列表
@interface GKPhotosGridViewController : GKCollectionViewController

///资源信息
@property(nonatomic, strong) GKPhotosCollection *collection;

///选项
@property(nonatomic, strong) GKPhotosOptions *photosOptions;

@end

