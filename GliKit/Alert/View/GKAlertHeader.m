//
//  GKAlertHeader.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKAlertHeader.h"

@implementation GKAlertHeader

@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;
@synthesize messageLabel = _messageLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (UILabel*)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel*)messageLabel
{
    if(!_messageLabel){
        _messageLabel = [UILabel new];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_messageLabel];
    }
    
    return _messageLabel;
}
- (UIImageView*)imageView
{
    if(!_imageView){
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

@end
