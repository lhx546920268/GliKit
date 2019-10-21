//
//  GKTabMenuBarItem.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/18.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTabMenuBarItem.h"

@implementation GKTabMenuBarItem

+ (instancetype)itemWithTitle:(NSString*) title
{
    GKTabMenuBarItem *item = [[GKTabMenuBarItem alloc] init];
    item.title = title;
    
    return item;
}


@end
