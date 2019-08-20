//
//  UIViewController+CAEmptyView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/7/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIViewController+CAEmptyView.h"
#import "UIView+CAEmptyView.h"

@implementation UIViewController (CAEmptyView)

- (void)setCa_showEmptyView:(BOOL)ca_showEmptyView
{
    self.view.ca_showEmptyView = ca_showEmptyView;
}

- (BOOL)ca_showEmptyView
{
    return self.view.ca_showEmptyView;
}

- (GKEmptyView*)ca_emptyView
{
    return self.view.ca_emptyView;
}

@end
