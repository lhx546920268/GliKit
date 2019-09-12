//
//  GKMenuBarItem.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKMenuBarItem.h"

@implementation GKMenuBarItem

+ (instancetype)itemWithTitle:(NSString*) title
{
    GKMenuBarItem *item = [[GKMenuBarItem alloc] init];
    item.title = title;
    
    return item;
}


@end
