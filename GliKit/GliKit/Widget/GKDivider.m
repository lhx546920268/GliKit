//
//  GKDivider.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKDivider.h"
#import "GKBaseDefines.h"
#import "UIView+GKAutoLayout.h"
#import "UIColor+GKTheme.h"
#import "UIApplication+GKTheme.h"

@interface GKDivider ()

///是否是垂直的
@property(nonatomic, assign) BOOL isVertical;

@end

@implementation GKDivider

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        NSLayoutConstraint *constraint = self.gkWidthLayoutConstraint;
        self.isVertical = constraint != nil;
        
        [self initProps];
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
        [self initProps];
    }
    
    return self;
}

+ (instancetype)verticalDivider
{
     return [[GKDivider alloc] initWithFrame:CGRectZero vertical:YES];
}

///初始化
- (void)initProps
{
    self.userInteractionEnabled = NO;
    self.backgroundColor = UIColor.gkSeparatorColor;
    if(self.isVertical){
        
        NSLayoutConstraint *constraint = self.gkWidthLayoutConstraint;
        if(!constraint){
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(UIApplication.gkSeparatorHeight);
            }];
            
        }else{
            constraint.constant = UIApplication.gkSeparatorHeight;
        }
    }else{
        NSLayoutConstraint *constraint = self.gkHeightLayoutConstraint;
        if(!constraint){
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(UIApplication.gkSeparatorHeight);
            }];
        }else{
            constraint.constant = UIApplication.gkSeparatorHeight;
        }
    }
}

@end
