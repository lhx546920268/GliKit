//
//  UITableViewCell+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/4/4.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

///行扩展
@interface UITableViewCell (GKUtils)

///获取行高 子类重写
@property(class, nonatomic, readonly) CGFloat gkRowHeight;

///获取估算的行高 子类重写
@property(class, nonatomic, readonly) CGFloat gkEstimatedRowHeight;

@end

///行扩展
@interface UITableViewHeaderFooterView (GKUtils)

///对应的section
@property(nonatomic, assign) NSUInteger gkSection;

///获取行高 子类重写
@property(class, nonatomic, readonly) CGFloat gkRowHeight;

///获取估算的行高 子类重写
@property(class, nonatomic, readonly) CGFloat gkEstimatedRowHeight;

@end

