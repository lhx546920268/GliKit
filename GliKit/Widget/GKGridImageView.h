//
//  GKGridImageView.h
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import <UIKit/UIKit.h>

///九宫格图片布局 使用的时候通过init 初始化，高度和宽度会根据图片数量和每行图片数量自动调整，可在xib中使用
@interface GKGridImageView : UIView

///图片每行最大数量 default is '3'
@property(nonatomic,assign) int maxCountPerRow;

///图片间隔 default is '10'
@property(nonatomic,assign) CGFloat interval;

///图片大小 default is '75.0'
@property(nonatomic,assign) int imageSize;

///留在复用的视图，数组元素是 UIImageView，建议一个viewController 只有一个，用来复用的
@property(nonatomic,strong) NSMutableSet *reusedCells;

///要显示的图片，如果和以前的images不一样，会调用reloadData
@property(nonatomic,strong) NSArray<NSString*> *images;

///点击某张图片
@property(nonatomic,copy) void(^selectImageHandler)(NSString *url, NSInteger index);

///刷新数据
- (void)reloadData;

///获取cell
- (UIImageView*)cellForIndex:(NSInteger) index;

/**
 通过图片数量获取视图高度
 */
- (CGFloat)heightForImageCount:(NSInteger) count;

/**
 通过图片数量获取视图高度 使用默认的图片间隔和每行图片数量
 */
+ (CGFloat)heightForImageCount:(NSInteger) count imageSize:(CGFloat) imageSize;

/**
 通过图片数量、图片间隔和每行图片数量获取视图高度
 */
+ (CGFloat)heightForImageCount:(NSInteger) count imageSize:(CGFloat) imageSize interval:(CGFloat) interval countPerRow:(int) countPerRow showWithOriginalScaleWhenOnlyOneImage:(BOOL) flag;

@end

