//
//  GKMenuBarItem.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKMenuBarItem.h"

@implementation GKMenuBarItem

+ (id)infoWithTitle:(NSString*) title
{
    GKMenuBarItem *info = [[GKMenuBarItem alloc] init];
    info.title = title;
    
    return info;
}


@end
