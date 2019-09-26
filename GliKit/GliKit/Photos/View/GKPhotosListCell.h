//
//  GKPhotosListCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///相册列表
@interface GKPhotosListCell : UITableViewCell

///缩略图
@property(nonatomic, readonly) UIImageView *thumbnailImageView;

///标题
@property(nonatomic, readonly) UILabel *titleLabel;

///数量
@property(nonatomic, readonly) UILabel *countLabel;

///asset标识符
@property(nonatomic, strong, nullable) NSString *assetLocalIdentifier;

@end

NS_ASSUME_NONNULL_END

