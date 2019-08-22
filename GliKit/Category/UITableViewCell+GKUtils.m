//
//  UITableViewCell+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/4.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UITableViewCell+GKUtils.h"
#import <objc/runtime.h>

static char GKTableViewHeaderFooterViewSectionKey;

@implementation UITableViewCell (GKUtils)

+ (CGFloat)gkRowHeight
{
    return 0;
}

+ (CGFloat)gkEstimatedRowHeight
{
    return 0;
}

@end

@implementation UITableViewHeaderFooterView (GKUtils)

- (void)setGkSection:(NSUInteger)gkSection
{
    objc_setAssociatedObject(self, &GKTableViewHeaderFooterViewSectionKey, @(gkSection), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)gkSection
{
    return [objc_getAssociatedObject(self, &GKTableViewHeaderFooterViewSectionKey) unsignedIntegerValue];
}

+ (CGFloat)gkRowHeight
{
    return 0;
}

+ (CGFloat)gkEstimatedRowHeight
{
    return 0;
}

@end
