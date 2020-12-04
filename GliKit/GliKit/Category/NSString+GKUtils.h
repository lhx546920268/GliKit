//
//  NSString+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 文字类型类型
 */
typedef NS_OPTIONS(NSUInteger, GKTextType){
    
    ///全部
    GKTextTypeAll = 1,
    
    ///数字
    GKTextTypeDigital = 1 << 1,
    
    ///英文字母
    GKTextTypeAlphabet = 1 << 2,
    
    ///小数 单独使用
    GKTextTypeDecimal = 1 << 4,
};

@interface NSString (GKUtils)

/**
 获取唯一字符串
 */
@property(nonatomic, class, readonly) NSString *gkUUID;

// MARK: - 空判断

/**
 判断字符串是否为空，会去掉 空格 \n \r
 */
+ (BOOL)isEmpty:(nullable NSString*) str;

/**
 判断字符串是否为空,字符串可以为空格
 */
+ (BOOL)isNull:(nullable NSString*) str;

// MARK: - 获取

/**
 第一个字符
 */
@property(nonatomic, readonly) char gkFirstCharacter;

/**
 最后一个字符
 */
@property(nonatomic, readonly) char gkLastCharacter;

/**
 从后面的字符串开始，获取对应字符的下标
 *@return 如果没有，返回NSNotFound
 */
- (NSInteger)gkLastIndexOfCharacter:(char) c;

/**
 return gk_stringSizeWithFont:(UIFont*) font contraintWith:CGFLOAT_MAX
 */
- (CGSize)gkStringSizeWithFont:(UIFont*) font;

/**
 获取字符串所占位置大小
 *@param font 字符串要显示的字体
 *@param width 每行最大宽度
 *@return 字符串大小
 */
- (CGSize)gkStringSizeWithFont:(UIFont*) font contraintWith:(CGFloat) width;

// MARK: - 校验

/**
 是否是纯数字
 */
@property(nonatomic, readonly) BOOL isDigitalOnly;

/**
 判断是否是整数
 */
@property(nonatomic, readonly) BOOL isInteger;

// MARK: - Hash

/**
 获取md5字符串
 */
@property(nonatomic, readonly) NSString *gkMD5String;

/**
 获取sha256字符串
 */
@property(nonatomic, readonly) NSString *gkSha256String;

// MARK: - 过滤

/**
 过滤字符串
 
 @param type 文字输入类型
 @return 过滤后的字符串
 */
- (NSString*)gkStringByFilterWithType:(GKTextType)type;

/**
 过滤字符串
 
 @param type 文字输入类型
 @param range 要过滤的范围
 @return 过滤后的字符串
 */
- (NSString*)gkStringByFilterWithType:(GKTextType) type range:(NSRange) range;

@end

@interface NSMutableString (GKUtils)

/**
 移除最后一个字符
 */
- (void)gkRemoveLastCharacter;

/**
 通过给定字符串，移除最后一个字符串
 */
- (void)gkRemoveLastString:(NSString*) str;

@end

@interface NSString(GKConversion)

///16进制转10进制
@property(nonatomic, readonly) NSInteger hexToDecimal;

///2进制转10进制
@property(nonatomic, readonly) NSInteger binaryToDecimal;

@end

NS_ASSUME_NONNULL_END
