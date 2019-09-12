//
//  UIViewController+GKEmptyView.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIViewController+GKEmptyView.h"
#import "UIView+GKEmptyView.h"

@implementation UIViewController (GKEmptyView)

- (void)setGkShowEmptyView:(BOOL)gkShowEmptyView
{
    self.view.gkShowEmptyView = gkShowEmptyView;
}

- (BOOL)gkShowEmptyView
{
    return self.view.gkShowEmptyView;
}

- (GKEmptyView*)gkEmptyView
{
    return self.view.gkEmptyView;
}

@end
