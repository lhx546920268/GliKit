//
//  UITableView+GKRowHeight.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 缓存行高的
 
 这样设置才行
 self.tableView.estimatedRowHeight = 80;
 
 //缓存
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSNumber *number = [tableView gk_rowHeightForIndexPath:indexPath];
 return number ? number.floatValue : UITableViewAutomaticDimension;
 }
 
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 [tableView gk_setRowHeight:@(cell.mj_h) forIndexPath:indexPath];
 }
 */
@interface UITableView (GKRowHeight)

///获取行高
- (NSNumber*)gk_rowHeightForIndexPath:(NSIndexPath*) indexPath;

///设置行高
- (void)gk_setRowHeight:(NSNumber*) rowHeight forIndexPath:(NSIndexPath*) indexPath;

///获取区域头部
- (NSNumber*)gkHeaderHeightForSection:(NSInteger) section;

///设置区域头部高度
- (void)gk_setHeaderHeight:(NSNumber*) headerHeight forSection:(NSInteger) section;

///获取区域底部高度
- (NSNumber*)gkFooterHeightForSection:(NSInteger) section;

///设置区域底部高度
- (void)gk_setFooterHeight:(NSNumber*) footerHeight forSection:(NSInteger) section;

@end

