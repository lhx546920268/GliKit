//
//  GKDChildPageViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDChildPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKChildPageListCell : UICollectionViewCell

///
@property(nonatomic, readonly) UILabel *textLabel;

@end

@implementation GKChildPageListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [UILabel new];
        [self.contentView addSubview:_textLabel];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
        }];
    }
    return self;
}

@end

@interface GKDChildPageViewController ()


@end

@implementation GKDChildPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews
{
    [self registerClass:[GKChildPageListCell class]];
    self.collectionView.gkNestedScrollEnabled = YES;
    [super initViews];
  //  self.refreshEnable = YES;
    self.loadMoreEnabled = YES;
    [self stopLoadMoreWithMore:YES];
}

- (void)onRefesh
{
    [super onRefesh];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)onLoadMore
{
    [super onLoadMore];
    [self performSelector:@selector(stopLoadMoreWithMore:) withObject:@(NO) afterDelay:2.0];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 130;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKChildPageListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKChildPageListCell.gkNameOfClass forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld个", indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSLog(@"click child");
}

@end
