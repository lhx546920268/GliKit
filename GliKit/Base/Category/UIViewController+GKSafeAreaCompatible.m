//
//  UIViewController+GKSafeAreaCompatible.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+GKSafeAreaCompatible.h"

@implementation UIViewController (GKSafeAreaCompatible)

- (MASViewAttribute*)gk_safeAreaLayoutGuideTop
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideTop;
    }else{
        return self.mas_topLayoutGuideBottom;
    }
}

- (MASViewAttribute*)gk_safeAreaLayoutGuideBottom
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideBottom;
    }else{
        return self.mas_bottomLayoutGuideTop;
    }
}

- (MASViewAttribute*)gk_safeAreaLayoutGuideLeft
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideLeft;
    }else{
        return self.view.mas_leading;
    }
}

- (MASViewAttribute*)gk_safeAreaLayoutGuideRight
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideRight;
    }else{
        return self.view.mas_trailing;
    }
}

@end
