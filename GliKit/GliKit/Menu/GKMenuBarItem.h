//
//  GKMenuBarItem.h
//  GliKit
//
//  Created by 罗海雄 on 2019/10/21.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
菜单按钮信息
*/
@interface GKMenuBarItem : NSObject

/**
 按钮内容大小
 */
@property(nonatomic, assign) CGSize contentSize;

/**
 按钮宽度
 */
@property(nonatomic, assign) CGFloat itemWidth;

@end

NS_ASSUME_NONNULL_END
