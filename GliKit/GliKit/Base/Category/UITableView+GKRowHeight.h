//
//  UITableView+GKRowHeight.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 缓存行高的
 
 这样设置才行
 self.tableView.estimatedRowHeight = 80;
 
 //缓存
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSNumber *number = [tableView gkRowHeightForIndexPath:indexPath];
 return number ? number.floatValue : UITableViewAutomaticDimension;
 }
 
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 [tableView gkSetRowHeight:@(cell.gkHeight) forIndexPath:indexPath];
 }
 */
@interface UITableView (GKRowHeight)

///获取行高
- (nullable NSNumber*)gkRowHeightForIndexPath:(NSIndexPath*) indexPath;

///设置行高
- (void)gkSetRowHeight:(nullable NSNumber*) rowHeight forIndexPath:(NSIndexPath*) indexPath;

///获取区域头部
- (NSNumber*)gkHeaderHeightForSection:(NSInteger) section;

///设置区域头部高度
- (void)gkSetHeaderHeight:(NSNumber*) headerHeight forSection:(NSInteger) section;

///获取区域底部高度
- (NSNumber*)gkFooterHeightForSection:(NSInteger) section;

///设置区域底部高度
- (void)gkSetFooterHeight:(NSNumber*) footerHeight forSection:(NSInteger) section;

@end

NS_ASSUME_NONNULL_END
