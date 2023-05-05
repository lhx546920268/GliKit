//
//  UIColor+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIColor+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation UIColor (GKUtils)

- (NSDictionary<NSString*, NSNumber*>*)gkColorARGB
{
    CGFloat red, green, blue, alpha;
    
    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if(success){
        return @{
            GKColorRed: @(red),
            GKColorGreen: @(green),
            GKColorBlue: @(blue),
            GKColorAlpha: @(alpha),
        };
    }
    
    return nil;
}

- (BOOL)isEqualToColor:(UIColor*) color
{
    if(!color)
        return NO;
    NSDictionary *dic1 = [self gkColorARGB];
    NSDictionary *dic2 = [color gkColorARGB];
    
    if(dic1 == nil || dic2 == nil)
        return NO;
    
    CGFloat R1 = [dic1[GKColorRed] floatValue];
    CGFloat G1 = [dic1[GKColorGreen] floatValue];
    CGFloat B1 = [dic1[GKColorBlue] floatValue];
    CGFloat A1 = [dic1[GKColorAlpha] floatValue];
    
    CGFloat R2 = [dic2[GKColorRed] floatValue];
    CGFloat G2 = [dic2[GKColorGreen] floatValue];
    CGFloat B2 = [dic2[GKColorBlue] floatValue];
    CGFloat A2 = [dic2[GKColorAlpha] floatValue];
    
    return R1 == R2 && B1 == B2 && G1 == G2 && A1 == A2;
}

- (NSString*)gkColorHex
{
    NSDictionary *dic = [self gkColorARGB];
    if(dic != nil){
        int R = [dic[GKColorRed] floatValue] * 255;
        int G = [dic[GKColorGreen] floatValue] * 255;
        int B = [dic[GKColorBlue] floatValue] * 255;
        CGFloat A = [dic[GKColorAlpha] floatValue];
        
        return [UIColor gkColorHexFromRed:R green:G blue:B alpha:A];
    }
    return @"ff000000";
}

- (BOOL)isLightColor
{
    CGFloat red, green, blue, alpha;
    
    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];
    if (success) {
        CGFloat grayLevel = red * 0.299 + green * 0.587 + blue * 0.114; //转成YUV
        if (grayLevel * 255 >= 192) {
            return YES;
        }
    }
    return NO;
}

- (UIColor*)gkColorWithAlpha:(CGFloat) alpha
{
    NSDictionary *dic = [self gkColorARGB];
    if(dic != nil){
        int R = [dic[GKColorRed] floatValue] * 255;
        int G = [dic[GKColorGreen] floatValue] * 255;
        int B = [dic[GKColorBlue] floatValue] * 255;
        
        return [UIColor gkColorWithRed:R green:G blue:B alpha:alpha];
    }
    return self;
}

+ (NSDictionary<NSString*, NSNumber*>*)gkColorARGBFromHex:(NSString*) hex
{
    if([NSString isEmpty:hex])
        return nil;
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    CGFloat alpha = 255.0f;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    NSInteger length = hex.length;
    NSInteger hexValue = hex.hexToDecimal;
    
    switch (length) {
        case 3 : {
            red = (hexValue & 0xf00) >> 8;
            green = (hexValue & 0x0f0) >> 4;
            blue = (hexValue & 0x00f);
        }
            break;
        case 4 : {
            alpha = (hexValue & 0xf000) >> 12;
            red = (hexValue & 0x0f00) >> 8;
            green = (hexValue & 0x00f0) >> 4;
            blue = (hexValue & 0x000f);
        }
            break;
        case 6 : {
            red = (hexValue & 0xff0000) >> 16;
            green = (hexValue & 0x00ff00) >> 8;
            blue = (hexValue & 0x0000ff);
        }
            break;
        case 8 : {
            alpha = (hexValue & 0xff000000) >> 24;
            red = (hexValue & 0x00ff0000) >> 16;
            green = (hexValue & 0x0000ff00) >> 8;
            blue = (hexValue & 0x000000ff);
        }
            break;
        default:
            break;
    }
    
    return @{
        GKColorRed: @(red / 255.0f),
        GKColorGreen: @(green / 255.0f),
        GKColorBlue: @(blue / 255.0f),
        GKColorAlpha: @(alpha / 255.0f),
    };
}

+ (NSString*)gkColorHexFromRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha
{
    int a = alpha * 255;
    return [NSString stringWithFormat:@"%02x%02x%02x%02x", a, red, green, blue];
}

+ (UIColor*)gkColorFromHex:(NSString*) hex
{
    NSDictionary *dic = [self gkColorARGBFromHex:hex];
    CGFloat red = [dic[GKColorRed] floatValue];
    CGFloat green = [dic[GKColorGreen] floatValue];
    CGFloat blue = [dic[GKColorBlue] floatValue];
    CGFloat alpha = [dic[GKColorAlpha] floatValue];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*)gkColorFromHex:(NSString*) hex alpha:(CGFloat) alpha
{
    NSDictionary *dic = [self gkColorARGBFromHex:hex];
    CGFloat red = [dic[GKColorRed] floatValue];
    CGFloat green = [dic[GKColorGreen] floatValue];
    CGFloat blue = [dic[GKColorBlue] floatValue];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*)gkColorWithRed:(int) red green:(int) green blue:(int) blue alpha:(CGFloat) alpha
{
    red = MIN(255, abs(red));
    green = MIN(255, abs(green));
    blue = MIN(255, abs(blue));
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}

@end
