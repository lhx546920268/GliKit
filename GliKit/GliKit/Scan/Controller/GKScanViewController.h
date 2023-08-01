//
//  GKScanViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKBaseScanViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GKScanBackgroundView;

///默认的二维码扫描
@interface GKScanViewController : GKBaseScanViewController

///二维码扫描背景
@property (nonatomic, readonly) GKScanBackgroundView *scanBackgroundView;

@end

NS_ASSUME_NONNULL_END
