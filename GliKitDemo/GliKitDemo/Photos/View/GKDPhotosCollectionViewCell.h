//
//  GKDPhotosCollectionViewCell.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDPhotosCollectionViewCell : UICollectionViewCell

///图片
@property(nonatomic, readonly) UIImageView *imageView;

@property(nonatomic, readonly) UITextView *subtitleTextView;

@end

NS_ASSUME_NONNULL_END
