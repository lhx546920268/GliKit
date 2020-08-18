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
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideTop;
    }else{
        return self.mas_topLayoutGuideBottom;
    }
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideBottom
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideBottom;
    }else{
        return self.mas_bottomLayoutGuideTop;
    }
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideLeft
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideLeft;
    }else{
        return self.view.mas_leading;
    }
}

- (MASViewAttribute*)gkSafeAreaLayoutGuideRight
{
    if(@available(iOS 11.0, *)){
        return self.view.mas_safeAreaLayoutGuideRight;
    }else{
        return self.view.mas_trailing;
    }
}

@end
