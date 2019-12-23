//
//  GKDRowModel.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDRowModel : NSObject

///xx
@property(nonatomic, strong) NSString *title;

///xx
@property(nonatomic, strong) NSString *className;

+ (instancetype)modelWithTitle:(NSString*) title clazz:(NSString*) clazz;

@end

NS_ASSUME_NONNULL_END
