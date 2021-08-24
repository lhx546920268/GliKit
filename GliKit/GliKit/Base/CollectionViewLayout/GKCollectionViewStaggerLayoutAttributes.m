//
//  GKCollectionViewStaggerLayoutAttributes.m
//  GliKit
//
//  Created by 罗海雄 on 2021/8/24.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKCollectionViewStaggerLayoutAttributes.h"
#import "GKCollectionViewStaggerLayout.h"

@implementation GKCollectionViewStaggerLayoutDecoratorView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if([layoutAttributes isKindOfClass:[GKCollectionViewStaggerLayoutDecoratorAttributes class]]){
        GKCollectionViewStaggerLayoutDecoratorAttributes *attr = (GKCollectionViewStaggerLayoutDecoratorAttributes*)layoutAttributes;
        [attr.layout.delegate collectionViewStaggerLayout:attr.layout configureDecorationView:self atSection:attr.indexPath.section];
    }
}

@end

@implementation GKCollectionViewStaggerLayoutDecoratorAttributes

@end

@implementation GKCollectionViewHeaderLayoutAttributes

- (instancetype)copyWithZone:(NSZone *)zone
{
    GKCollectionViewHeaderLayoutAttributes *attrs = [super copyWithZone:zone];
    attrs.sticking = self.sticking;
    
    return attrs;
}

@end

@implementation GKCollectionViewStaggerLayoutAttributes

@synthesize stickHeaderLayoutAttributes = _stickHeaderLayoutAttributes;

///section起点
- (CGFloat)sectionBeginning
{
    if(self.headerLayoutAttributes){
        return self.headerLayoutAttributes.frame.origin.y;
    }

    if(self.itemAttrs.count > 0){
        UICollectionViewLayoutAttributes *attrs = [self.itemAttrs firstObject];
        return attrs.frame.origin.y;
    }else{
        return self.footerLayoutAttributes.frame.origin.y;
    }
}

///section终点
- (CGFloat)sectionEnd
{
    if(self.footerLayoutAttributes){
        return self.footerLayoutAttributes.frame.origin.y + self.footerLayoutAttributes.frame.size.height;
    }

    if(self.itemAttrs.count > 0){
        return self.highestFrame.origin.y + self.highestFrame.size.height;
    }else{
        return self.headerLayoutAttributes.frame.origin.y + self.headerLayoutAttributes.frame.size.height;
    }
}

///是否存在元素
- (BOOL)existElement
{
    return self.headerLayoutAttributes != nil || self.itemAttrs.count > 0 || self.footerLayoutAttributes != nil;
}

///获取悬浮的header attr
- (GKCollectionViewHeaderLayoutAttributes*)stickHeaderLayoutAttributes
{
    if(self.headerLayoutAttributes){
        if(!_stickHeaderLayoutAttributes){
            _stickHeaderLayoutAttributes = [self.headerLayoutAttributes copy];
        }
        _stickHeaderLayoutAttributes.zIndex = NSNotFound;
        return _stickHeaderLayoutAttributes;
    }
    
    return nil;
}

///是否需要悬浮
- (BOOL)shouldStickHeader
{
    return _shouldStickHeader && self.headerLayoutAttributes;
}

@end
