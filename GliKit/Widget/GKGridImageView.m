//
//  GKGridImageView.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKGridImageView.h"

///默认属性
#define GKGridImageViewInterval 10.0 ///图片间隔
#define GKGridImageViewMaxCountPerRow 3 ///每行最大图片数量

///图片起始tag
#define GKGridImageViewStartTag 1000

@interface GKGridImageView ()


@end

@implementation GKGridImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialization];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

///初始化
- (void)initialization
{
    self.backgroundColor = [UIColor clearColor];
    self.interval = GKGridImageViewInterval;
    self.maxCountPerRow = GKGridImageViewMaxCountPerRow;
    self.imageSize = 75.0;
}

- (void)setImages:(NSArray<NSString*>*)images
{
    if(_images != images){
        _images = images;
        [self reloadData];
    }
}

///刷新数据
- (void)reloadData
{
    for(NSInteger i = 0;i < self.images.count;i ++){
        [self configCellForIndex:i];
    }
    
    ///移除无用的视图
    NSInteger i = self.images.count;
    while ([self cellForIndex:i]){
        [self removeCellAtIndex:i];
        i ++;
    }
}

///获取cell
- (UIImageView*)cellForIndex:(NSInteger) index
{
    return (UIImageView*)[self viewWithTag:GKGridImageViewStartTag + index];
}

#pragma mark private method

///配置cell
- (void)configCellForIndex:(NSInteger) index
{
    NSString *url = [self.images objectAtIndex:index];
    UIImageView *cell = [self cellForIndex:index];
    if(!cell){
        
        if(self.reusedCells.count > 0){
            cell = [self.reusedCells anyObject];
            [self.reusedCells removeObject:cell];
        }else{
            cell = [[UIImageView alloc] init];
            cell.contentMode = UIViewContentModeScaleAspectFill;
            cell.clipsToBounds = YES;
            cell.userInteractionEnabled = YES;
        }
        
        //移除以前的手势，防止重用时报错
        if(cell.gestureRecognizers.count > 0){
            [cell removeGestureRecognizer:[cell.gestureRecognizers firstObject]];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImage:)];
        [cell addGestureRecognizer:tap];
        
        [self addSubview:cell];
    }
    
    cell.tag = GKGridImageViewStartTag + index;
    NSInteger row = index / self.maxCountPerRow;
    NSInteger column = index % self.maxCountPerRow;
    
    cell.frame = CGRectMake(column * (self.imageSize + self.interval), row * (self.imageSize + self.interval), self.imageSize, self.imageSize);
    [cell sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:UIImage.appSquarePlaceholderImage];
}

///移除cell
- (void)removeCellAtIndex:(NSInteger) index
{
    UIImageView *cell = [self cellForIndex:index];
    if(cell)
    {
        [cell sd_setImageWithURL:nil];
        [self.reusedCells addObject:cell];
        [cell removeFromSuperview];
    }
}

///点击某个cell
- (void)handleTapImage:(UITapGestureRecognizer*) tap
{
    NSInteger index = tap.view.tag - GKGridImageViewStartTag;
    !self.selectImageHandler ?: self.selectImageHandler(self.images[index], index);
}

#pragma mark Class method

- (CGFloat)heightForImageCount:(NSInteger) count
{
    return [GKGridImageView heightForImageCount:count imageSize:self.imageSize interval:self.interval countPerRow:self.maxCountPerRow showWithOriginalScaleWhenOnlyOneImage:NO];
}

+ (CGFloat)heightForImageCount:(NSInteger) count imageSize:(CGFloat) imageSize
{
    return [GKGridImageView heightForImageCount:count imageSize:imageSize interval:GKGridImageViewInterval countPerRow:GKGridImageViewMaxCountPerRow showWithOriginalScaleWhenOnlyOneImage:NO];
}

+ (CGFloat)heightForImageCount:(NSInteger) count imageSize:(CGFloat) imageSize interval:(CGFloat) interval countPerRow:(int) countPerRow showWithOriginalScaleWhenOnlyOneImage:(BOOL)flag
{
    if(count == 0)
        return 0;
    else if (count == 1 && flag)
    {
        return imageSize * countPerRow;
    }
    else
    {
        NSInteger row = (count - 1) / countPerRow + 1;
        return row * imageSize + (row - 1) * interval;
    }
}


@end
