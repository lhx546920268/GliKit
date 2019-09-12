//
//  GKDNestedTableViewCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNestedTableViewCell.h"

@implementation GKDNestedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)handleClick:(id)sender {
    NSLog(@"点击了");
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *view = [super hitTest:point withEvent:event];
//    NSLog(@"cell %@", NSStringFromCGPoint(point));
//    
//    return view;
//}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touchesBegan");
//    //   [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touchesEnded");
//    //[super touchesEnded:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touchesCancelled");
//    // [super touchesCancelled:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touchesMoved");
//    // [super touchesMoved:touches withEvent:event];
//}

@end
