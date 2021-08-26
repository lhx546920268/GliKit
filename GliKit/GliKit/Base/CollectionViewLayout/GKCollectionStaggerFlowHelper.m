//
//  GKCollectionStaggerFlowHelper.m
//  GliKit
//
//  Created by 罗海雄 on 2021/8/24.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKCollectionStaggerFlowHelper.h"
#import "GKCollectionViewStaggerLayoutAttributes.h"
#import "UIScreen+GKUtils.h"

@implementation GKCollectionStaggerFlowHelper

- (instancetype)init
{
    self = [super init];
    if(self){
        self.outmostItemFrames = [NSMutableArray array];
        self.itemAttrs = [NSMutableArray array];
    }

    return self;
}

- (void)reset
{
    [self.outmostItemFrames removeAllObjects];
    [self.itemAttrs removeAllObjects];
    self.originY = 0;
    self.rightmost = 0;
    self.highestFrame = CGRectZero;
}

- (CGPoint)itemOriginFromItemSize:(CGSize) size
{
    CGPoint point;

    //该行没有其他item
    if(self.itemAttrs.count == 0){
        point.y = self.originY;
        point.x = self.layoutAttributes.sectionInset.left;
        self.rightmost = point.x + size.width;

        CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
        [self.outmostItemFrames addObject:@(rect)];
        [self updateHighestFrame:rect];
        
        return point;
    }

    CGFloat width = self.containerSize.width;
    if(width == 0){
        width = UIScreen.gkWidth;
    }
    
    if(size.width + self.layoutAttributes.sectionInset.right + self.layoutAttributes.minimumInteritemSpacing + self.rightmost >= width){
        //这一行已经没有位置可以放item了
        if(self.outmostItemFrames.count < 2){
            point.x = -1;
        }else{
            NSInteger index = [self traverseOutmostItemInfosWithItemSize:size];
            if(index >= self.outmostItemFrames.count){
                point.x = -1;
            }else{
                CGRect frame = [self.outmostItemFrames[index] CGRectValue];
                point.x = frame.origin.x;
               
                point.y = frame.size.height + frame.origin.y + self.layoutAttributes.minimumLineSpacing;

                CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
                if(size.width < frame.size.width){
                    //只挡住上面的item的一部分
                    CGRect relpacedRect = CGRectMake(point.x + size.width + self.layoutAttributes.minimumInteritemSpacing, frame.origin.y, frame.size.width - size.width - self.layoutAttributes.minimumInteritemSpacing, frame.size.height);
                    [self.outmostItemFrames replaceObjectAtIndex:index withObject:@(relpacedRect)];
                    
                    [self.outmostItemFrames insertObject:@(rect) atIndex:index];
                }else{
                    //已完全挡住上一个item
                    [self.outmostItemFrames replaceObjectAtIndex:index withObject:@(rect)];
                }
                [self updateHighestFrame:rect];

                //合并相同高度的item
                [self combineTheSameHeightItemForIndex:index];
            }
        }
    }else{
        //右边还有位置可以放item
        point.x = self.rightmost + self.layoutAttributes.minimumInteritemSpacing;
        point.y = self.originY;
        self.rightmost = point.x + size.width;

        CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
        if(self.outmostItemFrames.count == 0){
            [self.outmostItemFrames addObject:@(rect)];
        }else{
            CGRect lastRect = [[self.outmostItemFrames lastObject] CGRectValue];
            //相邻的item等高，合并
            if(rect.size.height == lastRect.size.height){
                lastRect.size.width += rect.size.width + self.layoutAttributes.minimumInteritemSpacing;
                [self.outmostItemFrames replaceObjectAtIndex:self.outmostItemFrames.count - 1 withObject:@(lastRect)];
            }else{
                [self.outmostItemFrames addObject:@(rect)];
            }
        }
        [self updateHighestFrame:rect];
    }

    return point;
}

///更新最高的frame
- (void)updateHighestFrame:(CGRect) frame
{
    if(frame.origin.y + frame.size.height > self.highestFrame.origin.y + self.highestFrame.size.height){
        self.highestFrame = frame;
    }
}

/// 遍历最外围的item，获取最低的并且适合放size的 item
/// @param size 将要存放的item的大小
/// @return 适合存放item的位置，如果返回NSNotFound，标明没有适合的位置
- (NSInteger)traverseOutmostItemInfosWithItemSize:(CGSize) size
{
    NSValue *value = [self.outmostItemFrames firstObject];
    CGRect frame = [value CGRectValue];

    NSInteger index = 0;
    for(NSInteger i = 1;i < self.outmostItemFrames.count;i ++){
        value = self.outmostItemFrames[i];
        CGRect rect = [value CGRectValue];
        //最低，并且可以放下item
        if(rect.origin.y + rect.size.height <= frame.origin.y + frame.size.height && rect.size.width >= size.width){
            if(rect.origin.y + rect.size.height == frame.origin.y + frame.size.height){
                //拿最左边的
                if(rect.origin.x < frame.origin.x){
                    frame = rect;
                    index = i;
                }
            }else{
                frame = rect;
                index = i;
            }
        }
    }

    if(size.width > frame.size.width){
        index = NSNotFound;
    }

    return index;
}

///合并相邻的相同高度的item
- (void)combineTheSameHeightItemForIndex:(NSInteger) index
{
    CGRect frame = [self.outmostItemFrames[index] CGRectValue];
    CGFloat bottom = frame.size.height + frame.origin.y;
    
    if(index > 0){
        //前一个
        CGRect pframe = [self.outmostItemFrames[index - 1] CGRectValue];
        CGFloat pBottom = pframe.origin.y + pframe.size.height;
        if(fabs(bottom - pBottom) < 1.0){
            pframe.origin.x = MIN(frame.origin.x, pframe.origin.x);
            pframe.size.width += frame.size.width + self.layoutAttributes.minimumInteritemSpacing;
            
             //防止出现白边
            if(self.layoutAttributes.minimumLineSpacing == 0){
                if(pBottom > bottom){
                    frame.size.height += pBottom - bottom;
                }else if (bottom > pBottom){
                    pframe.size.height += bottom - pBottom;
                }
            }
            
            [self.outmostItemFrames replaceObjectAtIndex:index withObject:@(pframe)];

            frame = pframe;
            [self.outmostItemFrames removeObjectAtIndex:index - 1];
        }
    }

    if(index + 1 < self.outmostItemFrames.count){
        //后一个
        CGRect pframe = [self.outmostItemFrames[index + 1] CGRectValue];
        CGFloat pBottom = pframe.origin.y + pframe.size.height;
        if(fabs(bottom - pBottom) < 1.0){
            pframe.origin.x = MIN(frame.origin.x, pframe.origin.x);
            pframe.size.width += frame.size.width + self.layoutAttributes.minimumInteritemSpacing;
            
            //防止出现白边
            if(self.layoutAttributes.minimumLineSpacing == 0){
                if(pBottom > bottom){
                    frame.size.height += pBottom - bottom;
                }else if (bottom > pBottom){
                    pframe.size.height += bottom - pBottom;
                }
            }
            
            [self.outmostItemFrames replaceObjectAtIndex:index withObject:@(pframe)];
            [self.outmostItemFrames removeObjectAtIndex:index + 1];
        }
    }
}

@end
