//
//  GKDDynamicBannerCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2022/9/22.
//  Copyright © 2022 luohaixiong. All rights reserved.
//

#import "GKDDynamicBannerCell.h"
#import <GKCollection>

///
@interface GKDDynamicBannerItem : UICollectionViewCell

///
@property(nonatomic, readonly) UILabel *textLabel;

@end

@implementation GKDDynamicBannerItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _textLabel = [UILabel new];
        [self.contentView addSubview:_textLabel];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
        }];
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.cornerRadius = 10;
    }
    
    return self;
}

@end

@interface GKDDynamicBannerCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

///
@property(nonatomic, strong) UICollectionView *collectionView;

@end

@implementation GKDDynamicBannerCell

+ (CGSize)gkItemSize
{
    return CGSizeMake(UIScreen.gkWidth - 30, 200);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        UICollectionViewFlowLayout *layout =[UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:GKDDynamicBannerItem.class forCellWithReuseIdentifier:GKDDynamicBannerItem.gkNameOfClass];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.contentView addSubview:_collectionView];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(0);
        }];
        
        
    }
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = indexPath.item == 0 ? 200 : 120;
    return CGSizeMake(collectionView.gkWidth, height);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDDynamicBannerItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:GKDDynamicBannerItem.gkNameOfClass forIndexPath:indexPath];
    item.textLabel.text = [NSString stringWithFormat:@"Banner %ld", indexPath.item];
    
    return item;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    
}

@end
