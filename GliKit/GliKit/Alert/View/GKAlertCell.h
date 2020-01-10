//
//  GKAlertCell.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKButton;

///弹窗按钮列表cell
@interface GKAlertCell : UICollectionViewCell

///按钮
@property(nonatomic, readonly) GKButton *button;

@end

NS_ASSUME_NONNULL_END

