//
//  GKPhotosPreviewViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKCollectionViewController.h"

@class PHAsset, GKPhotosOptions;

///相册预览
@interface GKPhotosPreviewViewController : GKCollectionViewController

///选项
@property(nonatomic, strong) GKPhotosOptions *photosOptions;

///资源信息
@property(nonatomic, strong) NSArray<PHAsset*> *assets;

//选中的图片
@property(nonatomic, strong) NSMutableArray<PHAsset*> *selectedAssets;

///当前可见下标
@property(nonatomic, assign) NSInteger visiableIndex;

@end

