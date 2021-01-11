//
//  GKSystemNavigationBar.h
//  GliKit
//
//  Created by 罗海雄 on 2019/6/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///导航栏
@interface GKSystemNavigationBar : UINavigationBar

///是否可以点击 默认 YES 直接设置 userInteractionEnabled 是无效的
@property(nonatomic, assign) BOOL enabled;

@end

