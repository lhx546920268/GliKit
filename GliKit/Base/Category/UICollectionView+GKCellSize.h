//
//  UICollectionView+GKCellSize.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///在计算cell大小时，要先配置cell内容，否则无法准确计算cell大小
typedef void(^GKCellConfiguration)(__kindof UICollectionReusableView *cell);

///cell大小
@interface UICollectionView (GKCellSize)

/**获取cell大小
 *@param identifier cell唯一标识
 *@param indexPath cell下标
 *@return cell大小
 */
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath configuration:(GKCellConfiguration) configuration;

/**获取cell大小
 *@param identifier cell唯一标识
 *@param indexPath cell下标
 *@param constraintSize 最大，只能设置 宽度或高度
 *@return cell大小
 */
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath constraintSize:(CGSize) constraintSize configuration:(GKCellConfiguration) configuration;

/**获取cell大小
 *@param identifier cell唯一标识
 *@param indexPath cell下标
 *@param width cell宽度
 *@return cell大小
 */
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath width:(CGFloat) width configuration:(GKCellConfiguration) configuration;

/**获取cell大小
 *@param identifier cell唯一标识
 *@param indexPath cell下标
 *@param height cell高度
 *@return cell大小
 */
- (CGSize)gkCellSizeForIdentifier:(NSString*) identifier indexPath:(NSIndexPath*) indexPath height:(CGFloat) height configuration:(GKCellConfiguration) configuration;


///头部
- (NSIndexPath*)gkHeaderIndexPathForSection:(NSInteger) section;

///底部
- (NSIndexPath*)gkFooterIndexPathForSection:(NSInteger) section;

@end

