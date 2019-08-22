//
//  NSJSONSerialization+GKUtils.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "NSJSONSerialization+GKUtils.h"
#import "NSString+GKUtils.h"

@implementation NSJSONSerialization (GKUtils)

+ (NSDictionary*)gkDictionaryFromString:(NSString *)string
{
    if([NSString isEmpty:string]){
        return nil;
    }
    
    return [self gkDictionaryFromData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSDictionary*)gkDictionaryFromData:(NSData*) data
{
    if(![data isKindOfClass:[NSData class]])
        return nil;
    
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error){
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"%@",error);
    }
    
    if([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }
    return nil;
}

+ (NSArray*)gkArrayFromString:(NSString*) string
{
    if([NSString isEmpty:string]){
        return nil;
    }
    
    return [self gkArrayFromData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSArray*)gkArrayFromData:(NSData*) data
{
    if(![data isKindOfClass:[NSData class]])
        return nil;
    
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error){
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"%@",error);
    }
    
    if([array isKindOfClass:[NSArray class]]){
        return array;
    }
    return nil;
}

+ (NSString*)gkStringFromObject:(id) object
{
    NSData *data = [self gkDataFromObject:object];
    if(data){
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return @"";
}

+ (NSData*)gkDataFromObject:(id) object
{
    if([NSJSONSerialization isValidJSONObject:object]){
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        
        if(error){
            NSLog(@"生成json 出错%@",error);
        }else{
            return data;
        }
    }
    
    return nil;
}

@end
