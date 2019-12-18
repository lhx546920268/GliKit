//
//  GKReactNativeVersionModel.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <GKObject.h>

NS_ASSUME_NONNULL_BEGIN

///rn版本信息
@interface GKReactNativeVersionModel : GKObject

///rn是否可以用
@property(nonatomic, assign) BOOL available;

///当前rn版本 这个和本地比对，如果不一样则下载更新
@property(nonatomic, copy) NSString *reactNativeVersion;

///rn下载链接
@property(nonatomic, copy) NSString *reactNativeDownloadURL;

@end

NS_ASSUME_NONNULL_END
