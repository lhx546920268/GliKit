//
//  UIColor+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UIColor+GKUtils.h"
#import "NSString+GKUtils.h"

///红
NSString *const GKColorRed = @"red";

///绿
NSString *const GKColorGreen = @"green";

///蓝
NSString *const GKColorBlue = @"blue";

///透明度
NSString *const GKColorAlpha = @"alpha";

@implementation UIColor (GKUtils)

- (NSDictionary<NSString*, NSNumber*>*)gkColorARGB
{
    CGFloat red, green, blue, alpha;
    
    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if(success){
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @(red), GKColorRed,
                @(green), GKColorGreen,
                @(blue), GKColorBlue,
                @(alpha), GKColorAlpha,
                nil];
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
    
    CGFloat R1 = [[dic1 objectForKey:GKColorRed] floatValue];
    CGFloat G1 = [[dic1 objectForKey:GKColorGreen] floatValue];
    CGFloat B1 = [[dic1 objectForKey:GKColorBlue] floatValue];
    CGFloat A1 = [[dic1 objectForKey:GKColorAlpha] floatValue];
    
    CGFloat R2 = [[dic2 objectForKey:GKColorRed] floatValue];
    CGFloat G2 = [[dic2 objectForKey:GKColorGreen] floatValue];
    CGFloat B2 = [[dic2 objectForKey:GKColorBlue] floatValue];
    CGFloat A2 = [[dic2 objectForKey:GKColorAlpha] floatValue];
    
    return R1 == R2 && B1 == B2 && G1 == G2 && A1 == A2;
}

- (NSString*)gkColorHex
{
    NSDictionary *dic = [self gkColorARGB];
    if(dic != nil)
    {
        int R = [[dic objectForKey:GKColorRed] floatValue] * 255;
        int G = [[dic objectForKey:GKColorGreen] floatValue] * 255;
        int B = [[dic objectForKey:GKColorBlue] floatValue] * 255;
        CGFloat A = [[dic objectForKey:GKColorAlpha] floatValue];
        
        return [UIColor gkColorHexFromRed:R green:G blue:B alpha:A];
    }
    return @"ff000000";
}

+ (NSDictionary<NSString*, NSNumber*>*)gkColorARGBFromHex:(NSString*) hex
{
    if([NSString isEmpty:hex])
        return nil;
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hex = [hex lowercaseString];
    
    CGFloat alpha = 255.0f;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    int index = 0;
    int len = 0;
    NSInteger length = hex.length;
    switch (length) {
        case 3 :
        case 4 : {
            len = 1;
            if(length == 4){
                int a = [self gkDecimalFromHexChar:[hex characterAtIndex:index]];
                alpha = a * 16 + a;
                index += len;
            }
            int value = [self gkDecimalFromHexChar:[hex characterAtIndex:index]];
            red = value * 16 + value;
            index += len;
            
            value = [self gkDecimalFromHexChar:[hex characterAtIndex:index]];
            green = value * 16 + value;
            index += len;
            
            value = [self gkDecimalFromHexChar:[hex characterAtIndex:index]];
            blue = value * 16 + value;
        }
            break;
        case 6 :
        case 8 : {
            len = 2;
            if(length == 8){
                alpha = [self gkDecimalFromHex:[hex substringWithRange:NSMakeRange(index, len)]];
                index += len;
            }
            red = [self gkDecimalFromHex:[hex substringWithRange:NSMakeRange(index, len)]];
            index += len;
            
            green = [self gkDecimalFromHex:[hex substringWithRange:NSMakeRange(index, len)]];
            index += len;
            
            blue = [self gkDecimalFromHex:[hex substringWithRange:NSMakeRange(index, len)]];
        }
            break;
        default:
            break;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @(red / 255.0f), GKColorRed,
            @(green / 255.0f), GKColorGreen,
            @(blue / 255.0f), GKColorBlue,
            @(alpha / 255.0f), GKColorAlpha,
            nil];
}

+ (NSString*)gkColorHexFromRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha
{
    int a = alpha * 255;
    return [NSString stringWithFormat:@"%02x%02x%02x%02x", a, red, green, blue];
}

+ (UIColor*)gkColorFromHex:(NSString*) hex
{
    NSDictionary *dic = [self gkColorARGBFromHex:hex];
    CGFloat red = [[dic objectForKey:GKColorRed] floatValue];
    CGFloat green = [[dic objectForKey:GKColorGreen] floatValue];
    CGFloat blue = [[dic objectForKey:GKColorBlue] floatValue];
    CGFloat alpha = [[dic objectForKey:GKColorAlpha] floatValue];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*)gkColorFromHex:(NSString*) hex alpha:(CGFloat) alpha
{
    NSDictionary *dic = [self gkColorARGBFromHex:hex];
    CGFloat red = [[dic objectForKey:GKColorRed] floatValue];
    CGFloat green = [[dic objectForKey:GKColorGreen] floatValue];
    CGFloat blue = [[dic objectForKey:GKColorBlue] floatValue];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/**
 获取10进制
 *@param hex 16进制
 *@return 10进制值
 */
+ (int)gkDecimalFromHex:(NSString*) hex
{
    int result = 0;
    int than = 1;
    for(NSInteger i = hex.length - 1;i >= 0;i --){
        char c = [hex characterAtIndex:i];
        
        result += [self gkDecimalFromHexChar:c] * than;
        than *= 16;
    }
    return result;
}

/**
 获取10进制
 *@param c 16进制
 *@return 10进制值
 */
+ (int)gkDecimalFromHexChar:(char) c
{
    int value;
    switch (c) {
        case 'A' :
        case 'a' :
            value = 10;
            break;
        case 'B' :
        case 'b' :
            value = 11;
            break;
        case 'C' :
        case 'c' :
            value = 12;
            break;
        case 'D' :
        case 'd' :
            value = 13;
            break;
        case 'E' :
        case 'e' :
            value = 14;
            break;
        case 'F' :
        case 'f' :
            value = 15;
            break;
        default:
            value = [[NSString stringWithFormat:@"%c", c] intValue];;
            break;
    }
    return value;
}

+ (UIColor*)gkColorWithRed:(int) red green:(int) green blue:(int) blue alpha:(CGFloat) alpha
{
    red = MIN(255, abs(red));
    green = MIN(255, abs(green));
    blue = MIN(255, abs(blue));
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}

@end
