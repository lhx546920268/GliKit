//
//  NSDate+GKUtils.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///大写的Y会导致时间多出一年

//yyyy-MM-dd HH:mm:ss
static NSString *const GKDateFormatYMdHms = @"yyyy-MM-dd HH:mm:ss";

//yyyy-MM-dd HH:mm
static NSString *const GKDateFormatYMdHm = @"yyyy-MM-dd HH:mm";

//yyyy-MM-dd
static NSString *const GKDateFormatYMd = @"yyyy-MM-dd";

@interface NSDate (Utils)

/**
 NSDateFormatter 的单例 因为频繁地创建 NSDateFormatter 是非常耗资源的、耗时的
 */
+ (NSDateFormatter*)sharedDateFormatter;

// MARK: - 单个时间

///获取当前时间的 秒
@property(nonatomic, readonly) int gkSecond;

///获取当前时间的 分
@property(nonatomic, readonly) int gkMinute;

///获取当前时间的 小时
@property(nonatomic, readonly) int gkHour;

///获取当前时间的 日期
@property(nonatomic, readonly) int gkDay;

///获取当前时间的 月份
@property(nonatomic, readonly) int gkMonth;

///获取当前时间的 年份
@property(nonatomic, readonly) int gkYear;

///获取当前时间的 星期几 1-7 星期日 到星期六
@property(nonatomic, readonly) NSInteger gkWeekday;

// MARK: - 时间获取

/**
 获取当前时间格式为 YYYY-MM-dd HH:mm:ss
 */
@property(class, nonatomic, readonly) NSString *gkCurrentTime;

/**
 通过给的格式获取当前时间
 *@param format 时间格式， 如 YYYY-MM-dd HH:mm:ss
 *@return 当前时间
 */
+ (NSString*)gkCurrentTimeWithFormat:(NSString*) format;

/**
 以当前时间为准，获取以后或以前的时间 时间格式为YYYY-MM-dd HH:mm:ss
 *@param timeInterval 时间间隔 大于0时，获取以后的时间,小于0时，获取以前的时间
 *@return 时间
 */
+ (nullable NSString*)gkTimeWithTimeInterval:(NSTimeInterval) timeInterval;

/**
 以当前时间为准，获取以后或以前的时间
 *@param timeInterval 时间间隔 大于0时，获取以后的时间,小于0时，获取以前的时间
 *@param format 时间格式为，如YYYY-MM-dd HH:mm:ss
 *@return 时间
 */
+ (nullable NSString*)gkTimeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString*) format;

/**
 通过给定时间，获取以后或以前的时间
 *@param timeInterval 时间间隔 大于0时，获取以后的时间,小于0时，获取以前的时间
 *@param format 时间格式为，如YYYY-MM-dd HH:mm:ss
 *@param fromTime 以该时间为准
 *@return 时间
 */
+ (nullable NSString*)gkTimeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format fromTime:(nullable NSString*) fromTime;

// MARK: - 时间转换

/**
 时间格式转换 从@"YYYY-MM-dd HH:mm:ss" 转换成给定格式
 *@param time 要格式化的时间
 *@param format 要转换成的格式
 *@retrun 转换后的时间
 */
+ (nullable NSString*)gkFormatTime:(NSString*) time format:(NSString*) format;

/**
 时间格式转换
 *@param time 要转换的时间
 *@param fromFormat 要转换的时间的格式
 *@param toFormat 要转换成的格式
 *@retrun 转换后的时间
 */
+ (nullable NSString*)gkFormatTime:(NSString*) time fromFormat:(NSString*) fromFormat toFormat:(NSString*) toFormat;

/**
 通过时间戳获取具体时间
 *@param timeInterval 时间戳，是距离1970年到当前的秒
 *@param format 要返回的时间格式
 *@return 具体时间
 */
+ (nullable NSString*)gkFormatTimeInterval:(NSTimeInterval) timeInterval format:(NSString*) format;

/**
 通过时间获取时间戳
 *@param time 时间
 *@param format 时间格式
 *@return 时间戳
 */
+ (NSTimeInterval)gkTimeIntervalFromTime:(NSString*) time format:(NSString*) format;

/**
 从时间字符串中获取date
 *@param time 时间字符串
 *@param format 时间格式
 *@return 时间date
 */
+ (nullable NSDate*)gkDateFromTime:(NSString*) time format:(NSString*) format;

/**
 从date获取时间字符串
 *@param date 时间
 *@param format 时间格式
 *@return 格式化的时间
 */
+ (nullable NSString*)gkTimeFromDate:(NSDate*) date format:(NSString*) format;

/**
 格式化秒
 @param seconds 要格式化的秒
 @return 00:00:00
 */
+ (NSString*)gkFormatSeconds:(long) seconds;

// MARK: - 时间比较

/**
 time - 当前时间 > timeInterval
 *@param time 要比较的时间
 *@param timeInterval 要大于的值
 */
+ (BOOL)gkTimeMinusNow:(NSString*) time greaterThan:(NSTimeInterval) timeInterval;

/**
 time1 - time2 > timeInterval
 *@param time1 要比较的时间1
 *@param time2 要比较的时间2
 *@param timeInterval 要大于的值
 */
+ (BOOL)gkTimeMinus:(NSString*) time1 time:(NSString*) time2 greaterThan:(NSTimeInterval) timeInterval;

/**比较两个时间是否相等
 */
+ (BOOL)gkTime:(NSString*) time1 equalToTime:(NSString*) time2;

// MARK: - other

/**当前时间和随机数生成的字符串
 *@return 如 1989072407080998
 */
+ (NSString*)gkRandom;

/**
 计算时间距离现在有多少秒
 */
+ (NSTimeInterval)gkTimeIntervalFromNow:(NSString*) time;

@end
NS_ASSUME_NONNULL_END

