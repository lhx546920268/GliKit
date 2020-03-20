//
//  GKTextField.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/21.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTextField.h"

@implementation GKTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    rect.origin.x = self.contentInsets.left;
    rect.origin.y = self.contentInsets.top;
    rect.size.width -= self.contentInsets.left + self.contentInsets.right;
    rect.size.height -= self.contentInsets.top + self.contentInsets.bottom;
    
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    rect.origin.x = self.contentInsets.left;
    rect.origin.y = self.contentInsets.top;
    rect.size.width -= self.contentInsets.left + self.contentInsets.right;
    rect.size.height -= self.contentInsets.top + self.contentInsets.bottom;
    
    return rect;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
    rect.origin.x = self.contentInsets.left;
    rect.origin.y = self.contentInsets.top;
    rect.size.width -= self.contentInsets.left + self.contentInsets.right;
    rect.size.height -= self.contentInsets.top + self.contentInsets.bottom;
    
    return rect;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *actions = self.forbiddenActions;

    if(actions.count > 0){
        if([actions containsObject:NSStringFromSelector(action)]){
            return NO;
        }
    }
    
    return [super canPerformAction:action withSender:sender];
}

@end
