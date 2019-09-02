//
//  NSDate+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "NSDate+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation NSDate (Utils)

//MARK: 单例

+ (NSDateFormatter*)sharedDateFormatter
{
    static dispatch_once_t once = 0;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&once, ^(void){
        
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    return dateFormatter;
}

//MARK: 单个时间

- (int)gkSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:self];
    return (int)components.second;
}

- (int)gkMinute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self];
    return (int)components.minute;
}

- (int)gkHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self];
    return (int)components.hour;
}

- (int)gkDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return (int)components.day;
}

- (int)gkMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    return (int)components.month;
}

- (int)gkYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    return (int)components.year;
}

- (NSInteger)gkWeekday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:self];
    
    return components.weekday;
}

//MARK: 时间获取

+ (NSString*)gkCurrentTime
{
    return [NSDate gkCurrentTimeWithFormat:GKDateFormatYMdHms];
}

+ (NSString*)gkCurrentTimeWithFormat:(NSString*) format
{
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    [dateFormatter setDateFormat:format];
    
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    return time;
}

+ (NSString*)gkTimeWithTimeInterval:(NSTimeInterval)timeInterval
{
    return [NSDate gkTimeWithTimeInterval:timeInterval format:GKDateFormatYMdHms];
}

+ (NSString*)gkTimeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString*) format
{
    return [NSDate gkTimeWithTimeInterval:timeInterval format:format fromTime:nil];
}

+ (NSString*)gkTimeWithTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format fromTime:(NSString*) fromTime
{
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    [dateFormatter setDateFormat:format];
    
    NSDate *oldDate = fromTime == nil ? [NSDate date] : [dateFormatter dateFromString:fromTime];
    
    NSDate *date = [NSDate dateWithTimeInterval:timeInterval sinceDate:oldDate];
    
    return [dateFormatter stringFromDate:date];
}

//MARK: 时间转换

+ (NSString*)gkFormatTime:(NSString*) time format:(NSString*) format
{
    return [NSDate gkFormatTime:time fromFormat:GKDateFormatYMdHms toFormat:format];
}

+ (NSString*)gkFormatTime:(NSString*) time fromFormat:(NSString*) fromFormat toFormat:(NSString*) toFormat
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:fromFormat];
    
    NSDate *date = [formatter dateFromString:time];
    
    [formatter setDateFormat:toFormat];
    NSString *timeStr = [formatter stringFromDate:date];
    
    return timeStr;
}

+ (NSString*)gkFormatTimeInterval:(NSTimeInterval) timeInterval format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    if(timeInterval > 100000000000){
        timeInterval /= 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return [formatter stringFromDate:date];
}

+ (NSTimeInterval)gkTimeIntervalFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSince1970];
}

+ (NSDate*)gkDateFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:time];
    return date;
}

+ (NSString*)gkTimeFromDate:(NSDate*) date format:(NSString*) format
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+ (NSString*)gkFormatSeconds:(long)seconds
{
    long result = seconds / 60;
    int second = (int)(seconds % 60);
    int minute = (int)(result % 60);
    int hour =(int)(result / 60);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
}

//MARK: 时间比较

+ (BOOL)gkTimeMinusNow:(NSString*) time greaterThan:(NSTimeInterval) timeInterval
{
    return [NSDate gkTimeMinus:time time:[NSDate gkCurrentTime] greaterThan:timeInterval];
}

+ (BOOL)gkTimeMinus:(NSString *)time1 time:(NSString*) time2 greaterThan:(NSTimeInterval)timeInterval
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

+ (BOOL)gkTime:(NSString*) time1 equalToTime:(NSString*) time2
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:GKDateFormatYMdHms];
    
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    return [date1 isEqualToDate:date2];
}

//MARK: other

+ (NSString*)gkRandom
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

+ (NSTimeInterval)gkTimeIntervalFromNow:(NSString*) time
{
    NSDateFormatter *formatter = [NSDate sharedDateFormatter];
    [formatter setDateFormat:GKDateFormatYMdHms];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSinceNow];
}

@end
