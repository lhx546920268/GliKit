//
//  GKTextField.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/21.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKTextField.h"

@implementation GKTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
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

@end
