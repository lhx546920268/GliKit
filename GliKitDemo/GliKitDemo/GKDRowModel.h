//
//  GKDRowModel.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDRowModel : NSObject<NSSecureCoding, NSMutableCopying>

///xx
@property(nonatomic, strong) NSString *title;

///xx
@property(nonatomic, strong) NSString *className;

///xx
@property(nonatomic, assign) NSInteger index;

///xx
@property(nonatomic, assign) int intValue;

///xx
@property(nonatomic, assign) BOOL boolValue;

///xx
@property(nonatomic, assign) CGRect rectValue;

+ (instancetype)modelWithTitle:(NSString*) title clazz:(NSString*) clazz;

@end

NS_ASSUME_NONNULL_END
