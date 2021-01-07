//
//  GKDRowModel.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, GKTestOptions) {
    
    GKTestOptionsOne = 1,
    
    GKTestOptionsTwo = 1 << 1,
    
    GKTestOptionsThree = 1 << 2,
    
    GKTestOptionsFour = 1 << 3,
};

static NSString *myStaticTest = @"my test";

@protocol GKDRowModelProtocol <NSObject>

///xx
@property(nonatomic, strong) NSString *className;

@end

@interface GKDRowModel : NSObject<NSSecureCoding, NSMutableCopying, GKDRowModelProtocol>
{
   @private NSString *_stringValue;
}

///xx
@property(nonatomic, strong) NSString *title;

///xx
@property(nonatomic, assign) NSInteger index;

///xx
@property(nonatomic, assign) int intValue;

///xx
@property(nonatomic, assign) BOOL boolValue;

///xx
@property(nonatomic, assign) CGRect rectValue;

///x
@property(nonatomic, readonly) NSString *stringValue;

+ (instancetype)modelWithTitle:(NSString*) title clazz:(NSString*) clazz;

@end

NS_ASSUME_NONNULL_END
