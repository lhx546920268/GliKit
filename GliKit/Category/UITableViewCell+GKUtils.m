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

+ (CGFloat)gk_rowHeight
{
    return 0;
}

+ (CGFloat)gk_estimatedRowHeight
{
    return 0;
}

@end

@implementation UITableViewHeaderFooterView (GKUtils)

- (void)setCa_section:(NSUInteger)gk_section
{
    objc_setAssociatedObject(self, &GKTableViewHeaderFooterViewSectionKey, @(gk_section), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)gk_section
{
    return [objc_getAssociatedObject(self, &GKTableViewHeaderFooterViewSectionKey) unsignedIntegerValue];
}

+ (CGFloat)gk_rowHeight
{
    return 0;
}

+ (CGFloat)gk_estimatedRowHeight
{
    return 0;
}

@end
