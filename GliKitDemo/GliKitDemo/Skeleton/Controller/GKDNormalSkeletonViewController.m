//
//  GKDNormalSkeletonViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/3.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNormalSkeletonViewController.h"
#import <UIView+GKSkeleton.h>
#import <SDWebImage.h>

@implementation SOLabel


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    // set inital value via IVAR so the setter isn't called
    self.verticalAlignment = VerticalAlignmentTop;

    return self;
}

-(void) setVerticalAlignment:(VerticalAlignment)value
{
    _verticalAlignment = value;
    [self setNeedsDisplay];
}

// align text block according to vertical alignment settings
-(CGRect)textRectForBounds:(CGRect)bounds
    limitedToNumberOfLines:(NSInteger)numberOfLines
{
   CGRect rect = [super textRectForBounds:bounds
                   limitedToNumberOfLines:numberOfLines];
    CGRect result;
    switch (_verticalAlignment)
    {
       case VerticalAlignmentTop:
          result = CGRectMake(bounds.origin.x, bounds.origin.y,
                              rect.size.width, rect.size.height);
           break;

       case VerticalAlignmentMiddle:
          result = CGRectMake(bounds.origin.x,
                    bounds.origin.y + (bounds.size.height - rect.size.height) / 2,
                    rect.size.width, rect.size.height);
          break;

       case VerticalAlignmentBottom:
          result = CGRectMake(bounds.origin.x,
                    bounds.origin.y + (bounds.size.height - rect.size.height),
                    rect.size.width, rect.size.height);
          break;

       default:
          result = bounds;
          break;
    }
    return result;
}

-(void)drawTextInRect:(CGRect)rect
{
    CGRect r = [self textRectForBounds:rect
                limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
}

@end

@interface GKDNormalSkeletonViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;

@property (weak, nonatomic) IBOutlet SOLabel *label;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation GKDNormalSkeletonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"普通骨架";
    self.label.verticalAlignment = VerticalAlignmentTop;
    
    WeakObj(self)
    [self.view gkShowSkeletonWithDuration:0.5 completion:^{
        [selfWeak hideSkeleton];
    }];
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    [UIStackView new];
    [self.imageView gkSetCornerRadius:20 corners:UIRectCornerTopRight];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)]];
    self.textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://cdn.weimob.com/saas/activity/bargain/css/font.svg?t=1509359605871"]];
}


- (void)hideSkeleton
{
    [self.view gkHideSkeletonWithAnimate:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *view = UIScreen.mainScreen.focusedView;
    NSLog(@"%@", view);
}

- (void)handleTap
{
    [UIView animateWithDuration:0.25 animations:^{
        NSLayoutConstraint *constraint = self.textView.gkHeightLayoutConstraint;
        constraint.constant = constraint.constant == 20 ? 200 : 20;
        [self.view layoutIfNeeded];
    }];
//    [self.imageView gkSetCornerRadius:10 corners:UIRectCornerBottomRight rect:self.imageView.frame];
}

@end
