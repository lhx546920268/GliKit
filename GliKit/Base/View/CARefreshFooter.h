//
//  GKRefreshFooter.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "MJRefreshAutoNormalFooter.h"

///加载更多 MJRefreshAutoStateFooter
@interface GKRefreshFooter : MJRefreshAutoNormalFooter

///是否需要显示菊花 加载中的时候， default is 'YES'
@property(nonatomic, assign) BOOL shouldDisplayIndicator;

@end

