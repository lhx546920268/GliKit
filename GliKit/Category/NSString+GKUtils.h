//
//  NSString+GKUtils.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#pragma mark 空判断

/**
 判断字符串是否为空，会去掉 空格 \n \r
 */
+ (BOOL)isEmpty:(NSString*) str;

/**
 判断字符串是否为空,字符串可以为空格
 */
+ (BOOL)isNull:(NSString*) str;

#pragma mark- 获取

/**
 第一个字符
 */
- (char)gk_firstCharacter;

/**
 最后一个字符
 */
- (char)gk_lastCharacter;

/**
 从后面的字符串开始，获取对应字符的下标
 *@return 如果没有，返回NSNotFound
 */
- (NSInteger)gk_lastIndexOfCharacter:(char) c;

/**
 return gk_stringSizeWithFont:(UIFont*) font contraintWith:CGFLOAT_MAX
 */
- (CGSize)gk_stringSizeWithFont:(UIFont*) font;

/**
 获取字符串所占位置大小
 *@param font 字符串要显示的字体
 *@param width 每行最大宽度
 *@return 字符串大小
 */
- (CGSize)gk_stringSizeWithFont:(UIFont*) font contraintWith:(CGFloat) width;

#pragma mark 图片

/**
 获取缩略图路径

 @param size 缩略图大小
 @return 缩略图路径
 */
- (NSString*)thumbnailURLWithSize:(CGSize) size;

#pragma mark 校验

/**
 是否是缅甸手机号
 */
- (BOOL)isMyanmarMobile;

/**
 是否是纯数字
 */
- (BOOL)isDigitalOnly;

/**
 判断是否是整数
 */
- (BOOL)isInteger;

#pragma mark 加密

///获取md5字符串
- (NSString*)gk_MD5String;

///获取加密的手机号
- (NSString*)encryptedMobile;

#pragma mark 过滤

/**
 过滤字符串
 
 @param type 文字输入类型
 @return 过滤后的字符串
 */
- (NSString*)gk_stringByFilterWithType:(GKTextType)type;

/**
 过滤字符串
 
 @param type 文字输入类型
 @param range 要过滤的范围
 @return 过滤后的字符串
 */
- (NSString*)gk_stringByFilterWithType:(GKTextType) type range:(NSRange) range;

@end

@interface NSMutableString (GKUtils)

/**
 移除最后一个字符
 */
- (void)gk_removeLastCharacter;

/**
 通过给定字符串，移除最后一个字符串
 */
- (void)gk_removeLastString:(NSString*) str;

@end
