//
//  UIFont+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "UIFont+GKUtils.h"

@implementation UIFont (GKUtils)

+ (UIFont*)appFontWithSize:(CGFloat) fontSize
{
    NSString *language = [GKLanguageHelper currentLanguage];
    UIFont *font = nil;
    if([language isEqualToString:GKLanguageHelper.mm3Name]){
        font = [UIFont fontWithName:@"Myanmar3" size:fontSize];
    }else if ([language isEqualToString:GKLanguageHelper.zawgyiName]){
        font = [UIFont fontWithName:@"Zawgyi-One" size:fontSize];
    }
    
    if(!font){
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    return font;
}

- (BOOL)isEqualToFont:(UIFont*) font
{
    if(!font)
        return NO;
    
    return [self.fontName isEqualToString:font.fontName] && self.pointSize == font.pointSize;
}

@end
