//
//  GKDialogManager.h
//  GliKit
//
//  Created by 罗海雄 on 2023/2/13.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗管理
@interface GKDialogManager : NSObject

///单例
@property(class, nonatomic, readonly) GKDialogManager *sharedManager;

@end

NS_ASSUME_NONNULL_END
