//
//  NSString+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSString+GKUtils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (GKUtils)

+ (BOOL)isEmpty:(NSString *)str
{
    if([str isEqual:[NSNull null]] || str == nil || str == NULL || ![str isKindOfClass:[NSString class]]){
        return YES;
    }
    
    if(str.length == 0){
        return YES;
    }
    
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(str.length == 0){
        return YES;
    }
    
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if(str.length == 0){
        return YES;
    }
    
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    if(str.length == 0){
        return YES;
    }
    
    return NO;
}

+ (BOOL)isNull:(NSString *)str
{
    if([str isEqual:[NSNull null]] || str == nil || str == NULL){
        return YES;
    }
    
    if(str.length == 0)
        return YES;
    
    return NO;
}

//MARK:- 获取

- (char)gkFirstCharacter
{
    if(self.length > 0){
        return [self characterAtIndex:0];
    }else{
        return 0;
    }
}

- (char)gkLastCharacter
{
    if(self.length > 0){
        return [self characterAtIndex:self.length - 1];
    }else{
        return 0;
    }
}

- (NSInteger)gkLastIndexOfCharacter:(char) c
{
    NSInteger index = NSNotFound;
    for(NSInteger i = self.length - 1;i >= 0;i --){
        char cha = [self characterAtIndex:i];
        if(cha == c){
            index = i;
            break;
        }
    }
    
    return index;
}

- (CGSize)gkStringSizeWithFont:(UIFont *)font
{
    return [self gkStringSizeWithFont:font contraintWith:CGFLOAT_MAX];
}

- (CGSize)gkStringSizeWithFont:(UIFont*) font contraintWith:(CGFloat) width
{
    CGSize size;
    CGSize contraintSize = CGSizeMake(width, CGFLOAT_MAX);
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    size = [self boundingRectWithSize:contraintSize  options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    
    return size;
}

//MARK: 校验

- (BOOL)isInteger
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isDigitalOnly
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length == 0;
}

//MARK: 加密

- (NSString*)gkMD5String
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//MARK: 过滤

- (NSString*)gkStringByFilterWithType:(GKTextType)type
{
    return [self gkStringByFilterWithType:type range:NSMakeRange(0, self.length)];
}

- (NSString*)gkStringByFilterWithType:(GKTextType) type range:(NSRange) range
{
    if(type & GKTextTypeAll)
        return self;
    
    NSMutableString *regex = [NSMutableString stringWithString:@"[^"];
    
    if(type == GKTextTypeDecimal){
        [regex appendString:@"0-9\\."];
    }else{
        if(type & GKTextTypeDigital){
            [regex appendString:@"0-9"];
        }
        
        if(type & GKTextTypeAlphabet){
            [regex appendString:@"a-zA-Z"];
        }
    }
    
    [regex appendString:@"]"];
    
    return [self stringByReplacingOccurrencesOfString:regex withString:@"" options:NSRegularExpressionSearch range:range];;
}

@end


@implementation NSMutableString (GKUtils)

- (void)gkRemoveLastCharacter
{
    if(self.length == 0)
        return;
    [self deleteCharactersInRange:NSMakeRange(self.length - 1, 1)];
}

- (void)gkRemoveLastString:(NSString*) str
{
    if(self.length < str.length)
        return;
    [self deleteCharactersInRange:NSMakeRange(self.length - str.length, str.length)];
}

@end
