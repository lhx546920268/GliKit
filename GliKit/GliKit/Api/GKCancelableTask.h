//
//  GKCancelableTask.h
//  GliKit
//
//  Created by 罗海雄 on 2021/11/4.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

///可取消的任务
@protocol GKCancelableTask <NSObject>

///任务标识
@property(nonatomic, readonly) NSString *taskKey;

///取消
- (void)cancel;

@end
