//
//  GKCollectionViewTopFlowLayout.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 0 2 4 ---\  0 1 2
 1 3 5 ---/  3 4 5 计算转换后对应的item  原来'4'的item为4,转换后为3
 */
@interface GKCollectionViewTopFlowLayout : UICollectionViewFlowLayout

///每行数量
@property(nonatomic, assign) NSInteger itemCountPerRow;

///最大行数
@property(nonatomic, assign) NSInteger maxRowCount;

@end


