//
//  GKPhotosPreviewHeader.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPhotosCheckBox;

///相册预览头部
@interface GKPhotosPreviewHeader : UIView

///返回按钮
@property(nonatomic, readonly) UIButton *backButton;

///标题
@property(nonatomic, readonly) UILabel *titleLabel;

///选中
@property(nonatomic, readonly) GKPhotosCheckBox *checkBox;

@end

