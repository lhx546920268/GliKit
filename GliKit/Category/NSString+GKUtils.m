//
//  NSString+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSString+GKUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import "GKMobileOperatorModel.h"

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

#pragma mark- 获取

- (char)gk_firstCharacter
{
    if(self.length > 0){
        return [self characterAtIndex:0];
    }else{
        return 0;
    }
}

- (char)gk_lastCharacter
{
    if(self.length > 0){
        return [self characterAtIndex:self.length - 1];
    }else{
        return 0;
    }
}

- (NSInteger)gk_lastIndexOfCharacter:(char) c
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

- (CGSize)gk_stringSizeWithFont:(UIFont *)font
{
    return [self gk_stringSizeWithFont:font contraintWith:CGFLOAT_MAX];
}

- (CGSize)gk_stringSizeWithFont:(UIFont*) font contraintWith:(CGFloat) width
{
    CGSize size;
    CGSize contraintSize = CGSizeMake(width, CGFLOAT_MAX);
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    size = [self boundingRectWithSize:contraintSize  options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    
    return size;
}

#pragma mark 图片

- (NSString*)thumbnailURLWithSize:(CGSize) size
{
    return [self stringByAppendingFormat:@"@%.0fw_%.0fh", size.width, size.height];
}

#pragma mark 校验

- (BOOL)isMyanmarMobile
{
    if(self.length >= GKMobileMinLength && [self isDigitalOnly] && self.length <= GKMobileMaxLength){
        NSArray *models = [GKMobileOperatorModel mobileOperatorModels];
        for(GKMobileOperatorModel *model in models){
            for(GKMobileRuleModel *ruleModel in model.ruleModels){
                if(self.length == ruleModel.length && [self hasPrefix:ruleModel.prefix]){
                    return YES;
                }
            }
        }
    }
    return NO;
}

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

#pragma mark 加密

- (NSString*)gk_MD5String
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

- (NSString *)encryptedMobile
{
    if(self.length >= 7){
        return [NSString stringWithFormat:@"%@****%@", [self substringToIndex:3], [self substringFromIndex:self.length - 4]];
    }
    
    return self;
}

#pragma mark 过滤

- (NSString*)gk_stringByFilterWithType:(GKTextType)type
{
    return [self gk_stringByFilterWithType:type range:NSMakeRange(0, self.length)];
}

- (NSString*)gk_stringByFilterWithType:(GKTextType) type range:(NSRange) range
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

- (void)gk_removeLastCharacter
{
    if(self.length == 0)
        return;
    [self deleteCharactersInRange:NSMakeRange(self.length - 1, 1)];
}

- (void)gk_removeLastString:(NSString*) str
{
    if(self.length < str.length)
        return;
    [self deleteCharactersInRange:NSMakeRange(self.length - str.length, str.length)];
}

@end
