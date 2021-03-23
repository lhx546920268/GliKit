//
//  GKDCollectionEmptyViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDCollectionEmptyViewController.h"
#import <GKDivider.h>
#import <GKItemSizeModel.h>

@interface GKDCollectionEmptyModel : NSObject<GKItemSizeModel>

///
@property(nonatomic, copy) NSString *title;

@end

@implementation GKDCollectionEmptyModel

@synthesize itemSize;

@end

@interface GKDCollectionEmptyCell : UICollectionViewCell

@property(nonatomic, readonly) UILabel *textLabel;

@property(nonatomic, strong) GKDCollectionEmptyModel *model;

@end

@implementation GKDCollectionEmptyCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [UILabel new];
        [self.contentView addSubview:_textLabel];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(15, 25, 15, 25));
        }];
    
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.cornerRadius = 20;
    }
    return self;
}

- (void)setModel:(GKDCollectionEmptyModel *)model
{
    _model = model;
    _textLabel.text = _model.title;
}

@end

@interface GKDCollectionEmptyViewController ()

@property(nonatomic, assign) NSInteger count;

///
@property(nonatomic, strong) NSArray<GKDCollectionEmptyModel*> *models;

@end

@implementation GKDCollectionEmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger section, id<NSCollectionLayoutEnvironment> _Nonnull environment) {
        
        NSCollectionLayoutItem *item1 = [NSCollectionLayoutItem itemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:50] heightDimension:[NSCollectionLayoutDimension absoluteDimension:50]]];
        NSCollectionLayoutItem *item2 = [NSCollectionLayoutItem itemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:50] heightDimension:[NSCollectionLayoutDimension absoluteDimension:80]]];
        
        NSCollectionLayoutGroup *group = nil;
        if(section % 2 == 0){
            group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:UIScreen.gkWidth] heightDimension:[NSCollectionLayoutDimension estimatedDimension:50]] subitems:@[item1, item2]];
        }else{
            group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:UIScreen.gkWidth] heightDimension:[NSCollectionLayoutDimension estimatedDimension:50]] subitems:@[item2]];
            
            }
        
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:20];
        NSCollectionLayoutSection *layoutSection = [NSCollectionLayoutSection sectionWithGroup:group];
        if(section % 2 != 0){
            layoutSection.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorPaging;
        }
        return layoutSection;
    }];
    self.layout = layout;
    
    self.count = 10;
    NSMutableArray *models = [NSMutableArray array];
    
    self.view.backgroundColor = UIColor.gkGrayBackgroundColor;
    for(NSInteger i = 0;i < self.count;i ++){
        GKDCollectionEmptyModel *model = GKDCollectionEmptyModel.new;
        
        model.title = [NSString stringWithFormat:@"%d", rand()];
        [models addObject:model];
    }
    self.models = models;
    
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.flowLayout.minimumLineSpacing = 15;
    self.flowLayout.minimumInteritemSpacing = 15;
    [self registerClass:GKDCollectionEmptyCell.class];
    [self initViews];
    self.collectionView.gkShouldShowEmptyView = YES;
    self.refreshEnabled = YES;
}

- (void)onRefesh
{
    [super onRefesh];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2];
}

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    [super emptyViewWillAppear:view];
    if(view.gestureRecognizers.count == 0){
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEmpty)]];
    }
}

- (void)handleTapEmpty
{
    self.count = 30;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView gkCellSizeForIdentifier:GKDCollectionEmptyCell.gkNameOfClass model:self.models[indexPath.item]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDCollectionEmptyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDCollectionEmptyCell.gkNameOfClass forIndexPath:indexPath];
    cell.model = self.models[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.count = 0;
    [collectionView reloadData];
}

@end
