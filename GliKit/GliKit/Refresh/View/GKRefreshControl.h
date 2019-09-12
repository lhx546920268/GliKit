//
//  UIApplication+GKTheme.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDataControl.h"

/**
 下拉刷新控制视图
 */
@interface GKRefreshControl : GKDataControl

/**
 加载完成的提示信息 default is '刷新成功'
 */
@property(nonatomic,copy) NSString *finishText;

@end

