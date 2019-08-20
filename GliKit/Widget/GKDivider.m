//
//  GKDivider.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKDivider.h"

@interface GKDivider ()

///是否是垂直的
@property(nonatomic, assign) BOOL isVertical;

@end

@implementation GKDivider

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        NSLayoutConstraint *constraint = self.gk_widthLayoutConstraint;
        self.isVertical = constraint != nil;
        
        [self initialization];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame vertical:NO];
}

- (instancetype)initWithFrame:(CGRect)frame vertical:(BOOL) vertical
{
    self = [super initWithFrame:frame];
    if(self){
        self.isVertical = vertical;
        [self initialization];
    }
    
    return self;
}

+ (instancetype)verticalDivider
{
     return [[GKDivider alloc] initWithFrame:CGRectZero vertical:YES];
}

///初始化
- (void)initialization
{
    self.backgroundColor = UIColor.appSeparatorColor;
    if(self.isVertical){
        
        NSLayoutConstraint *constraint = self.gk_widthLayoutConstraint;
        if(!constraint){
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(GKSeparatorHeight);
            }];
            
        }else{
            constraint.constant = GKSeparatorHeight;
        }
    }else{
        NSLayoutConstraint *constraint = self.gk_heightLayoutConstraint;
        if(!constraint){
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(GKSeparatorHeight);
            }];
        }else{
            constraint.constant = GKSeparatorHeight;
        }
    }
}

@end
