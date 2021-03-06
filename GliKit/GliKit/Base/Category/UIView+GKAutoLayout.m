//
//  UIView+GKAutoLayout.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIView+GKAutoLayout.h"
#import <Masonry/Masonry.h>

@implementation UIView (GKAutoLayout)

- (BOOL)gkExistConstraints
{
    if(self.constraints.count > 0){
        return YES;
    }
    
    NSArray *contraints = self.superview.constraints;
    
    if(contraints.count > 0){
        for(NSLayoutConstraint *constraint in contraints){
            if(constraint.firstItem == self || constraint.secondItem == self){
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)gkRemoveAllContraints
{
    [self removeConstraints:self.constraints];
    NSArray *contraints = self.superview.constraints;
    
    if(contraints.count > 0){
        NSMutableArray *toClearContraints = [NSMutableArray array];
        for(NSLayoutConstraint *constraint in contraints){
            if(constraint.firstItem == self || constraint.secondItem == self){
                [toClearContraints addObject:constraint];
            }
        }
        [self.superview removeConstraints:toClearContraints];
    }
}

// MARK: - 获取约束 constraint

- (NSLayoutConstraint*)gkHeightLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeHeight];
}

- (NSLayoutConstraint*)gkWidthLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeWidth];
}

- (NSLayoutConstraint*)gkLeftLayoutConstraint
{
    NSLayoutConstraint *constraint = [self gkLayoutConstraintForAttribute:NSLayoutAttributeLeading];
    if(!constraint){
        constraint = [self gkLayoutConstraintForAttribute:NSLayoutAttributeLeft];
    }
    return constraint;
}

- (NSLayoutConstraint*)gkRightLayoutConstraint
{
    NSLayoutConstraint *constraint = [self gkLayoutConstraintForAttribute:NSLayoutAttributeTrailing];
    if(!constraint){
        constraint = [self gkLayoutConstraintForAttribute:NSLayoutAttributeRight];
    }
    return constraint;
}

- (NSLayoutConstraint*)gkTopLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeTop];
}

- (NSLayoutConstraint*)gkBottomLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeBottom];
}

- (NSLayoutConstraint*)gkCenterXLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeCenterX];
}

- (NSLayoutConstraint*)gkCenterYLayoutConstraint
{
    return [self gkLayoutConstraintForAttribute:NSLayoutAttributeCenterY];
}

- (NSLayoutConstraint*)gkLayoutConstraintForAttribute:(NSLayoutAttribute) attribute
{
    return [self gkLayoutConstraintForAttribute:attribute withSecondItem:nil];
}

- (NSLayoutConstraint*)gkLayoutConstraintForAttribute:(NSLayoutAttribute)attribute withSecondItem:(id)secondItem
{
    NSArray *constraints = nil;
    
    //符合条件的，可能有多个，取最高优先级的 忽略其子类
    NSMutableArray *matchs = [NSMutableArray array];
    
    switch (attribute)
    {
        case NSLayoutAttributeWidth :
        case NSLayoutAttributeHeight :
            
            //宽高约束主要有 固定值，纵横比，等于某个item的宽高
            constraints = self.constraints;
            for(NSLayoutConstraint *constraint in constraints){
                //固定值，纵横比 放在本身
                if([self gkConformToConstraint:constraint]){
                    if(constraint.firstAttribute == attribute && constraint.firstItem == self && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute){
                        //忽略纵横比
                        [matchs addObject:constraint];
                    }
                }
            }
            
            if(matchs.count == 0){
                //等于某个item的宽高 放在父视图
                constraints = self.superview.constraints;
                for(NSLayoutConstraint *constraint in constraints){
                    if([self gkConformToConstraint:constraint]){
                        if((constraint.firstAttribute == attribute && constraint.firstItem == self) || (constraint.secondAttribute == attribute && constraint.secondItem == self)){
                            //忽略纵横比
                            [matchs addObject:constraint];
                        }
                    }
                }
            }
            
            break;
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :
        case NSLayoutAttributeTop :
            //左上 约束 必定在父视图
            //item1.attribute1 = item2.attribute2 + constant
            //item2.attribute2 = item1.attribute1 - constant
            constraints = self.superview.constraints;
            for(NSLayoutConstraint *constraint in constraints){
                if([self gkConformToConstraint:constraint]){
                    if(constraint.firstItem == self && constraint.firstAttribute == attribute){
                        [matchs addObject:constraint];
                    }else if (constraint.secondItem == self && constraint.secondAttribute == attribute){
                        [matchs addObject:constraint];
                    }
                }
            }
            break;
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :
        case NSLayoutAttributeBottom :
            //右下约束 必定在父视图
            //item1.attribute1 = item2.attribute2 - constant
            //item2.attribute2 = item1.attribute1 + constant
            constraints = self.superview.constraints;
            for(NSLayoutConstraint *constraint in constraints){
                if([self gkConformToConstraint:constraint]){
                    if(constraint.firstItem == self && constraint.firstAttribute == attribute){
                        [matchs addObject:constraint];
                    }else if (constraint.secondItem == self && constraint.secondAttribute == attribute){
                        [matchs addObject:constraint];
                    }
                }
            }
            break;
        case NSLayoutAttributeCenterX :
        case NSLayoutAttributeCenterY :
            //居中约束 必定在父视图
            constraints = self.superview.constraints;
            for(NSLayoutConstraint *constraint in constraints){
                if([self gkConformToConstraint:constraint]){
                    if(constraint.firstItem == self && constraint.firstAttribute == attribute){
                        [matchs addObject:constraint];
                    }
                }
            }
            break;
        default:
            break;
    }
    
    NSLayoutConstraint *layoutConstraint = [matchs firstObject];
    //符合的约束太多，拿优先级最高的
    for(int i = 1;i < matchs.count;i ++){
        NSLayoutConstraint *constraint = matchs[i];
        if(secondItem){
            if(constraint.secondItem != secondItem && constraint.firstItem != secondItem){
                continue;
            }
        }
        if(layoutConstraint.priority < constraint.priority){
            layoutConstraint = constraint;
        }
    }
    
    return layoutConstraint;
}

///判断是否是自己设定的约束
- (BOOL)gkConformToConstraint:(id) constraint
{
    return [constraint isMemberOfClass:NSLayoutConstraint.class] || [constraint isMemberOfClass:MASLayoutConstraint.class];
}

// MARK: - AutoLayout 计算大小

- (CGSize)gkSizeThatFits:(CGSize) fitsSize type:(GKAutoLayoutCalcType) type
{
    CGSize size = CGSizeZero;
    if (type != GKAutoLayoutCalcTypeSize){
        //添加临时约束
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:type == GKAutoLayoutCalcTypeHeight ? NSLayoutAttributeWidth : NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:type == GKAutoLayoutCalcTypeHeight ? fitsSize.width : fitsSize.height];
        [self addConstraint:constraint];
        size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [self removeConstraint:constraint];

    }else{
        //添加临时约束
        NSLayoutConstraint *constraint = nil;
        if(!CGSizeEqualToSize(fitsSize, CGSizeZero)){
            constraint = [NSLayoutConstraint constraintWithItem:self attribute:fitsSize.width != 0 ? NSLayoutAttributeWidth : NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:fitsSize.width != 0 ? fitsSize.width : fitsSize.height];
            [self addConstraint:constraint];
        }
        
        
        size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        if(constraint != nil){
            [self removeConstraint:constraint];
        }
    }
    
    return size;
}

- (void)gkSetVerticalHugAndCompressionPriority:(UILayoutPriority) priority
{
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
}

- (void)gkSetHorizontalHugAndCompressionPriority:(UILayoutPriority) priority
{
    [self setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
}


@end
