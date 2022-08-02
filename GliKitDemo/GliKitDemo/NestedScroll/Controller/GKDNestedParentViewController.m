//
//  GKDNestedParentViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNestedParentViewController.h"
#import "GKDNestedPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKNestedSectionHeader : UICollectionReusableView

@end

@implementation GKNestedSectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [UILabel new];
        label.text = @"悬浮";
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
        }];
    }
    return self;
}

@end

@interface GKNestedCollectionViewCell : UICollectionViewCell

@end

@implementation GKNestedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"按钮" forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
        }];
    }
    return self;
}

@end

@interface GKDNestedPageCell : UICollectionViewCell

///要显示的viewController
@property(nonatomic, strong) UIViewController *viewController;

///父
@property(nonatomic, weak) UIViewController *parentViewController;

@end

@interface GKDNestedParentViewController ()

@property(nonatomic, strong) GKDNestedPageViewController *page;

@end

@implementation GKDNestedParentViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"/app/nested" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return [GKDNestedParentViewController new];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = [GKDNestedPageViewController new];
    
    [self initViews];
}

- (void)initViews
{
    [self registerClass:[GKNestedCollectionViewCell class]];
    [self registerClass:[GKDNestedPageCell class]];
    [self registerHeaderClass:GKNestedSectionHeader.class];
    
    self.collectionView.gkNestedParent = YES;
    self.collectionView.gkNestedScrollEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;

    [super initViews];
}

- (BOOL)shouldAdjustContentInsetForSafeArea
{
    return NO;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0 :
            return 0;
        case 1 :
            return 3;
        case 2 :
            return 1;
        default:
            break;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
     switch (indexPath.section) {
           case 0 :
               return CGSizeZero;
           case 1 :
               return CGSizeMake(collectionView.gkWidth, 45);
           case 2 :
               return CGSizeMake(collectionView.gkWidth, collectionView.gkHeight);
           default:
               break;
       }
       return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return section == 0 ? CGSizeMake(collectionView.gkWidth, 50) : CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GKNestedSectionHeader.gkNameOfClass forIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        GKNestedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKNestedCollectionViewCell.gkNameOfClass forIndexPath:indexPath];
        
        return cell;
    }else{
        GKDNestedPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDNestedPageCell.gkNameOfClass forIndexPath:indexPath];
        cell.parentViewController = self;
        cell.viewController = self.page;
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSLog(@"click parent");
}


@end

@implementation GKDNestedPageCell

- (void)setViewController:(UIViewController *)viewController
{
    if(_viewController != viewController){
        if(_viewController){
            [_viewController removeFromParentViewController];
            [_viewController.view removeFromSuperview];
        }
        
        _viewController = viewController;
        [self.contentView addSubview:_viewController.view];
        [self.parentViewController addChildViewController:_viewController];
        
        [_viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
    }
}

@end
