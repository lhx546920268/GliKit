//
//  GKDCollectionViewSkeletonCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDCollectionViewSkeletonCell.h"

@interface GKDCollectionViewSkeletonCell ()



@end

@implementation GKDCollectionViewSkeletonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        CGFloat size = (UIScreen.gkWidth - 10 * 4) / 3;
        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_1"]];
//        [self.contentView addSubview:imageView];
//
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.equalTo(CGSizeMake(size - 10, size - 10));
//            make.centerX.equalTo(@0);
//            make.top.equalTo(5);
//        }];
//
//        UILabel *label = [UILabel new];
//        label.text = @"标题";
//        label.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:label];
//
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(imageView.mas_bottom).offset(5);
//            make.leading.equalTo(5);
//            make.trailing.equalTo(-5);
//        }];
        
        
        self.animatedView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 20, 0)];
        self.animatedView.backgroundColor = UIColor.redColor;
        self.animatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.animatedView];
        
        self.contentView.backgroundColor = UIColor.whiteColor;
//        self.contentView.frame = self.bounds;
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

//- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
//{
//    [super applyLayoutAttributes:layoutAttributes];
//    [self layoutIfNeeded];
//}

@end
