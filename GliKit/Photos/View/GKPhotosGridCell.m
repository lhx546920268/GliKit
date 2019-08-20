//
//  GKPhotosGridCell.m
//  IOSLibrary
//
//  Created by 罗海雄 on 2019/7/2.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosGridCell.h"
#import "UIView+GKAutoLayout.h"
#import "GKPhotosCheckBox.h"
#import "GKBasic.h"
#import "UIColor+Utils.h"

@implementation GKPhotosGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _overlay = [UIView new];
        _overlay.hidden = YES;
        _overlay.userInteractionEnabled = NO;
        _overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self.contentView addSubview:_overlay];
        
        [_imageView gk_insetsInSuperview:UIEdgeInsetsZero];
        [_overlay gk_insetsInSuperview:UIEdgeInsetsZero];
        
        _checkBox = [GKPhotosCheckBox new];
        [_checkBox addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCheck)]];
        _checkBox.contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [self.contentView addSubview:_checkBox];
        
        [_checkBox gk_sizeToSelf:CGSizeMake(30, 30)];
        [_checkBox gk_rightToSuperview];
        [_checkBox gk_topToSuperview];
    }
    return self;
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    if(_checked != checked){
        _checked = checked;
        _overlay.hidden = !checked;
        [self.checkBox setChecked:checked animated:animated];
    }
}

//MARK: action

///选中
- (void)handleCheck
{
    if([self.delegate respondsToSelector:@selector(photosGridCellCheckedDidChange:)]){
        [self.delegate photosGridCellCheckedDidChange:self];
    }
}

@end
