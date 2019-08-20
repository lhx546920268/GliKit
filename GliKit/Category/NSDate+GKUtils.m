//
//  NSDate+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSDate+GKUtils.h"

@implementation NSDate (Utils)

#pragma mark 单例

+ (NSDateFormatter*)sharedDateFormatter
{
    static dispatch_once_t once = 0;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&once, ^(void){
        
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    return dateFormatter;
}

#pragma mark 单个时间

- (int)gk_second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:self];
    return (int)components.second;
}

- (int)gk_minute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self];
    return (int)components.minute;
}

- (int)gk_hour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self];
    return (int)components.hour;
}

- (int)gk_day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return (int)components.day;
}

- (int)gk_month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    return (int)components.month;
}

- (int)gk_year
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    return (int)components.year;
}

- (NSInteger)gk_weekday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:self];
    
    return components.weekday;
}

#pragma mark 时间获取

+ (NSString*)gk_currentTime
{
    return [NSDate gk_currentTimeWithFormat:GKDateFormatYMdHms];
}

+ (NSString*)gk_currentTimeWithFormat:(NSString*) format
{
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    [dateFormatter setDateFormat:format];
    
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    return time;
}

+ (NSString*)gk_timeWithTimeInterval:(NSTimeInterval)timeInterval
{
    return [NSDate gk_timeWithTimeInterval:timeInterval format:GKDateFormatYMdHms];
}

+ (NSString*)gk_timeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString*) format
{
    return [NSDate gk_timeWithTimeInterval:timeInterval format:format fromTime:nil];
}

+ (NSString*)gk_timeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format fromTime:(NSString*) fromTime
{
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    [dateFormatter setDateFormat:format];
    
    NSDate *oldDate = fromTime == nil ? [NSDate date] : [dateFormatter dateFromString:fromTime];
    
    NSDate *date = [NSDate dateWithTimeInterval:timeInterval sinceDate:oldDate];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark 时间转换

+ (NSString*)gk_formatTime:(NSString*) time format:(NSString*) format
{
    return [NSDate gk_formatTime:time fromFormat:GKDateFormatYMdHms toFormat:format];
}

+ (NSString*)gk_formatTime:(NSString*) time fromFormat:(NSString*) fromFormat toFormat:(NSString*) toFormat
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:fromFormat];
    
    NSDate *date = [formatter dateFromString:time];
    
    [formatter setDateFormat:toFormat];
    NSString *timeStr = [formatter stringFromDate:date];
    
    return timeStr;
}

+ (NSString*)gk_formatTimeInterval:(NSTimeInterval) timeInterval format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    if(timeInterval > 100000000000){
        timeInterval /= 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return [formatter stringFromDate:date];
}

+ (NSTimeInterval)gk_timeIntervalFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSince1970];
}

+ (NSDate*)gk_dateFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:time];
    return date;
}

+ (NSString*)gk_timeFromDate:(NSDate*) date format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+ (NSString*)formatSeconds:(long)seconds
{
    long result = seconds / 60;
    int second = (int)(seconds % 60);
    int minute = (int)(result % 60);
    int hour =(int)(result / 60);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
}

#pragma mark- 时间比较

+ (BOOL)gk_TimeMinusNow:(NSString*) time greaterThan:(NSTimeInterval) timeInterval
{
    return [NSDate gk_TimeMinus:time time:[NSDate gk_currentTime] greaterThan:timeInterval];
}

+ (BOOL)gk_TimeMinus:(NSString *)time1 time:(NSString*) time2 greaterThan:(NSTimeInterval)timeInterval
{
    if([NSString isEmpty:time1]){
        return YES;
    }
    
    if([NSString isEmpty:time2]){
        return YES;
    }
    
    
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    [dateFormatter setDateFormat:GKDateFormatYMdHms];
    
    NSDate *date1 = [dateFormatter dateFromString:time1];
    NSDate *date2 = [dateFormatter dateFromString:time2];
    
    return [date1 timeIntervalSinceDate:date2] > timeInterval;
}

+ (BOOL)gk_time:(NSString*) time1 equalToTime:(NSString*) time2
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:GKDateFormatYMdHms];
    
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    return [date1 isEqualToDate:date2];
}

#pragma mark- other

+ (NSString*)gk_random
{
    int iRandom = arc4random() % 1000000;
    if (iRandom < 0) {
        iRandom = -iRandom;
    }
    
    NSDateFormatter *tFormat = [NSDate sharedDateFormatter];
    [tFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *tResult = [NSString stringWithFormat:@"%@%d",[tFormat stringFromDate:[NSDate date]],iRandom];
    return tResult;
}

+ (NSTimeInterval)gk_timeIntervalFromNow:(NSString*) time
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:GKDateFormatYMdHms];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSinceNow];
}

@end
