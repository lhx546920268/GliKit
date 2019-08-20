//
//  UITableViewCell+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/4/4.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///行扩展
@interface UITableViewCell (GKUtils)

///获取行高 子类重写
@property(class, nonatomic, readonly) CGFloat gk_rowHeight;

///获取估算的行高 子类重写
@property(class, nonatomic, readonly) CGFloat gk_estimatedRowHeight;

@end

///行扩展
@interface UITableViewHeaderFooterView (GKUtils)

///对应的section
@property(nonatomic, assign) NSUInteger gk_section;

///获取行高 子类重写
@property(class, nonatomic, readonly) CGFloat gk_rowHeight;

///获取估算的行高 子类重写
@property(class, nonatomic, readonly) CGFloat gk_estimatedRowHeight;

@end

