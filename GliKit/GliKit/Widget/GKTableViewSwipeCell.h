//
//  GKTableViewSwipeCell.h
//  GliKit
//
//  Created by 罗海雄 on 2020/12/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKTableViewSwipeCell;

///滑动方向
typedef NS_OPTIONS(NSInteger, GKSwipeDirection) {
    
    ///没
    GKSwipeDirectionNone,
    
    ///向左
    GKSwipeDirectionLeft = 1 << 0,
    
    ///向右
    GKSwipeDirectionRight = 1 << 1,
};

///代理
@protocol GKTableViewSwipeCellDelegate <NSObject>

///获取按钮
- (NSArray<UIView*>*)tableViewSwipeCell:(GKTableViewSwipeCell*) cell swipeButtonsForDirection:(GKSwipeDirection) direction;

@end

///可滑动显示多个按钮的cell
@interface GKTableViewSwipeCell : UITableViewCell

///可以滑动的方向
@property(nonatomic, assign) GKSwipeDirection swipeDirection;

///代理
@property(nonatomic, weak) id<GKTableViewSwipeCellDelegate> delegate;

///切换按钮状态
- (void)setSwipeShow:(BOOL) show direction:(GKSwipeDirection) direction animated:(BOOL) animated;

@end

