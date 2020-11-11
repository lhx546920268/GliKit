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

// MARK: - 单例

+ (NSMutableDictionary<NSString*, NSDateFormatter*>*)sharedDateFormatters
{
    static dispatch_once_t once = 0;
    static NSMutableDictionary<NSString*, NSDateFormatter*> *dateFormatters = nil;
    dispatch_once(&once, ^(void){
        
        dateFormatters = [NSMutableDictionary dictionary];
    });
    
    return  dateFormatters;
}

+ (NSDateFormatter*)sharedDateFormatterForFormat:(NSString *)format
{
    NSMutableDictionary *formatters = [self sharedDateFormatters];
    NSDateFormatter *dateFormatter = formatters[format];
    if(!dateFormatter){
        @synchronized (self) {
            dateFormatter = formatters[format];
            if(!dateFormatter){
                dateFormatter = NSDateFormatter.new;
                dateFormatter.locale = NSLocale.currentLocale;
                formatters[format] = dateFormatter;
            }
        }
    }
    
    return dateFormatter;
}

// MARK: - 单个时间

- (int)gkSecond
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitSecond fromDate:self];
}

- (int)gkMinute
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitMinute fromDate:self];
}

- (int)gkHour
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitHour fromDate:self];
}

- (int)gkDay
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitDay fromDate:self];
}

- (int)gkMonth
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitMonth fromDate:self];
}

- (int)gkYear
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitYear fromDate:self];
}

- (NSInteger)gkWeekday
{
    return (int)[NSCalendar.currentCalendar component:NSCalendarUnitWeekday fromDate:self];
}

// MARK: - 时间获取

+ (NSString*)gkCurrentTime
{
    return [NSDate gkCurrentTimeWithFormat:GKDateFormatYMdHms];
}

+ (NSString*)gkCurrentTimeWithFormat:(NSString*) format
{
    NSDateFormatter *dateFormatter = [self sharedDateFormatterForFormat:format];
    return [dateFormatter stringFromDate:[NSDate date]];
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
    NSDateFormatter *dateFormatter = [self sharedDateFormatterForFormat:format];
    NSDate *oldDate = fromTime == nil ? [NSDate date] : [dateFormatter dateFromString:fromTime];
    NSDate *date = [NSDate dateWithTimeInterval:timeInterval sinceDate:oldDate];
    
    return [dateFormatter stringFromDate:date];
}

// MARK: - 时间转换

+ (NSString*)gkFormatTime:(NSString*) time format:(NSString*) format
{
    return [NSDate gkFormatTime:time fromFormat:GKDateFormatYMdHms toFormat:format];
}

+ (NSString*)gkFormatTime:(NSString*) time fromFormat:(NSString*) fromFormat toFormat:(NSString*) toFormat
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:fromFormat];
    NSDate *date = [formatter dateFromString:time];
    
    formatter = [self sharedDateFormatterForFormat:toFormat];
    
    return [formatter stringFromDate:date];
}

+ (NSString*)gkFormatTimeInterval:(NSTimeInterval) timeInterval format:(NSString*) format
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:format];
    
    if(timeInterval > 100000000000){
        timeInterval /= 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return [formatter stringFromDate:date];
}

+ (NSTimeInterval)gkTimeIntervalFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:format];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSince1970];
}

+ (NSDate*)gkDateFromTime:(NSString*) time format:(NSString*) format
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:format];
    return [formatter dateFromString:time];
}

+ (NSString*)gkTimeFromDate:(NSDate*) date format:(NSString*) format
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:format];
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

// MARK: - 时间比较

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
    
    
    NSDateFormatter *dateFormatter = [self sharedDateFormatterForFormat:GKDateFormatYMdHms];
    
    NSDate *date1 = [dateFormatter dateFromString:time1];
    NSDate *date2 = [dateFormatter dateFromString:time2];
    
    return [date1 timeIntervalSinceDate:date2] > timeInterval;
}

+ (BOOL)gkTime:(NSString*) time1 equalToTime:(NSString*) time2
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:GKDateFormatYMdHms];
    
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    return [date1 isEqualToDate:date2];
}

// MARK: - other

+ (NSTimeInterval)gkTimeIntervalFromNow:(NSString*) time
{
    NSDateFormatter *formatter = [self sharedDateFormatterForFormat:GKDateFormatYMdHms];
    
    NSDate *date = [formatter dateFromString:time];
    return [date timeIntervalSinceNow];
}

@end
