//
//  GKPhotosToolBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/7/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///相册工具条
@interface GKPhotosToolBar : UIView

///分割线
@property(nonatomic, readonly) UIView *divider;

///使用按钮
@property(nonatomic, readonly) UIButton *useButton;

///预览按钮
@property(nonatomic, readonly) UIButton *previewButton;

///选择的数量
@property(nonatomic, readonly) UILabel *countLabel;

///当前选的图片数量
@property(nonatomic, assign) int count;

@end

