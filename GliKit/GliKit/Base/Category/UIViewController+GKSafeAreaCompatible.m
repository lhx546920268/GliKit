//
//  UIViewController+GKSafeAreaCompatible.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKSafeAreaCompatible.h"
#import <Masonry/Masonry.h>

@implementation UIViewController (GKSafeAreaCompatible)

- (MASViewAttribute*)gkSafeAreaLayoutGuideTop
{
    return self.view.mas_safeAreaLayoutGuideTop;
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideBottom
{
    return self.view.mas_safeAreaLayoutGuideBottom;
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideLeft
{
    return self.view.mas_safeAreaLayoutGuideLeft;
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideRight
{
    return self.view.mas_safeAreaLayoutGuideRight;
}

@end
