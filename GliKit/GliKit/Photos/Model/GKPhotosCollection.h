//
//  GKPhotosCollection.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHAsset.h>

///相册分组信息
@interface GKPhotosCollection : NSObject

///标题
@property(nonatomic, copy) NSString *title;

///资源信息
@property(nonatomic, strong) PHFetchResult<PHAsset*> *assets;

@end

