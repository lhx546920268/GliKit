//
//  GKDSqliteViewController.m
//  GliKitDemo
//
//  Created by xiaozhai on 2023/7/17.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKDSqliteViewController.h"
#import "GKDDataBase.h"

@interface GKDSqliteViewController ()

///
@property(nonatomic, strong) GKDDataBase *dataBase;

@end

@implementation GKDSqliteViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"app/db" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDSqliteViewController new];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];

    NSCharacterSet *set = [[NSCharacterSet alloc] init];
    NSLog(@"%@", [self replaceUnicode:@"\u4f60"]);
}

- (void)handleStart
{
    NSLog(@"开始插入");
    GKDChatHistory *history = [GKDChatHistory new];
    history.content = @"这是一段很尝尝的聊通天塔家佛诶我就佛";
    history.status = 1;
    history.type = @"text";
    
    GKDDataBase *dataBase = [GKDDataBase new];
//    for (NSInteger i = 0; i < 10000000; i ++) {
//        history.sessionId = @(random() % 10000).stringValue;
//        history.receiverId = @(random() % 10000).stringValue;
//        history.uuid = NSUUID.UUID.UUIDString;
//        history.time = NSDate.date.timeIntervalSince1970;
//        [dataBase insertHistory:history];
//    }
//    NSLog(@"插入完成");
    
    
}

- (NSString*) replaceUnicode:(NSString*)TransformUnicodeString
{
    NSString*tepStr1 = [TransformUnicodeString stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString*tepStr2 = [tepStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString*tepStr3 = [[@"\""  stringByAppendingString:tepStr2]stringByAppendingString:@"\""];
    NSData*tepData = [tepStr3  dataUsingEncoding:NSUTF8StringEncoding];
    NSString*axiba = [NSPropertyListSerialization propertyListWithData:tepData options:NSPropertyListMutableContainers format:NULL error:NULL];
    return  [axiba    stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}



@end
