//
//  GKPhotosPreviewViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/11.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosPreviewViewController.h"
#import "GKPhotosOptions.h"
#import "GKPhotosPreviewCell.h"
#import "GKPhotosToolBar.h"
#import <Photos/Photos.h>
#import "GKContainer.h"
#import "GKPhotosCheckBox.h"
#import "UIView+GKAutoLayout.h"
#import "GKAlertController.h"
#import "UIViewController+GKUtils.h"
#import "UIScreen+GKUtils.h"
#import "UIViewController+GKLoading.h"
#import "GKBaseDefines.h"
#import "UIImage+GKUtils.h"
#import "GKNavigationBar.h"
#import "UIApplication+GKTheme.h"

@interface GKPhotosPreviewViewController ()<GKPhotosPreviewCellDelegate>

///底部工具条
@property(nonatomic, strong) GKPhotosToolBar *photosToolBar;

///选中
@property(nonatomic, readonly) GKPhotosCheckBox *checkBox;

///标题
@property(nonatomic, strong) UILabel *titleLabel;

///图片加载选项
@property(nonatomic, strong) PHImageRequestOptions *requestOptions;

@end

@implementation GKPhotosPreviewViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _imageSpacing = 15.0;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setNavigatonBarHidden:NO animate:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.requestOptions = [PHImageRequestOptions new];
    self.requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    self.requestOptions.networkAccessAllowed = YES;
    
    self.gkBackBarButtonItem.customView.tintColor = UIColor.whiteColor;
    self.navigatonBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    self.view.backgroundColor = UIColor.blackColor;
    
    [self initViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initViews
{
    self.container.safeLayoutGuide = GKSafeLayoutGuideNone;
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = self.imageSpacing;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, self.imageSpacing / 2.0, 0, self.imageSpacing / 2.0);
    
    [self registerClass:GKPhotosPreviewCell.class];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    [super initViews];
    
    CGFloat size = self.gkNavigationBarHeight;
    _checkBox = [[GKPhotosCheckBox alloc] initWithFrame:CGRectMake(0, 0, size - UIApplication.gkNavigationBarMargin * 2 + 6, size)];
    [_checkBox addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCheck)]];
    _checkBox.contentInsets = UIEdgeInsetsMake(10, UIApplication.gkNavigationBarMargin, 10, UIApplication.gkNavigationBarMargin);
    [self gkSetRightItemWithCustomView:_checkBox];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.gkNavigationBarHeight)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = _titleLabel;
    
    self.photosToolBar = [GKPhotosToolBar new];
    self.photosToolBar.backgroundColor = self.navigatonBar.backgroundView.backgroundColor;
    self.photosToolBar.previewButton.hidden = YES;
    self.photosToolBar.divider.hidden = YES;
    self.photosToolBar.countLabel.textColor = UIColor.whiteColor;
    [self.photosToolBar.useButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.photosToolBar.useButton addTarget:self action:@selector(handleUse) forControlEvents:UIControlEventTouchUpInside];
    self.photosToolBar.count = (int)self.selectedAssets.count;
    [self.view addSubview:self.photosToolBar];
    
    [self.photosToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
    }];
    
    [self updateTitle];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(self.visiableIndex > 0 && self.visiableIndex < self.assets.count){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.visiableIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.visiableIndex = 0;
        [self updateTitle];
    }
}

// MARK: - action

///设置工具条隐藏
- (void)setToolBarAndHeaderHidden:(BOOL) hidden
{
    if(!hidden){
        self.photosToolBar.hidden = hidden;
    }
    [self setNavigatonBarHidden:hidden animate:YES];
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.photosToolBar.gkBottomLayoutConstraint.constant = hidden ? self.photosToolBar.frame.size.height : 0;
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.photosToolBar.hidden = hidden;
    }];
}

//选中
- (void)handleCheck
{
    PHAsset *asset = self.assets[self.selectedIndex];
    if(self.checkBox.checked){
        self.checkBox.checked = NO;
        [self removeAsset:asset];
    }else{
        if(self.selectedAssets.count >= self.photosOptions.maxCount){
            
            [[GKAlertController alertWithTitle:[NSString stringWithFormat:@"您最多能选择%d张图片", (int)self.photosOptions.maxCount]
                                       message:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"我知道了"]] show];
            
        }else{
            [self.selectedAssets addObject:asset];
            self.checkBox.checkedText = [NSString stringWithFormat:@"%d", (int)self.selectedAssets.count];
            [self.checkBox setChecked:YES animated:YES];
        }
    }
    self.photosToolBar.count = (int)self.selectedAssets.count;
}

///使用
- (void)handleUse
{
    [self useAssets:self.selectedAssets];
}

///使用图片
- (void)useAssets:(NSArray<PHAsset*>*) assets
{
    [self gkShowLoadingToastWithText:nil];
    self.gkBackBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    WeakObj(self)
    __block NSInteger totalCount = assets.count;
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:totalCount];
    
    for(PHAsset *selectedAsset in assets){
        [PHImageManager.defaultManager requestImageDataForAsset:selectedAsset options:self.requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            totalCount --;
            if(imageData){
                [datas addObject:imageData];
            }
            if(totalCount <= 0){
                [selfWeak onImageDataLoad:datas];
            }
        }];
    }
}

///图片加载完成
- (void)onImageDataLoad:(NSArray<NSData*>*) datas
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:datas.count];
    
    WeakObj(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for(NSData *data in datas){
            GKPhotosPickResult *result = [GKPhotosPickResult resultWithData:data options:self.photosOptions];
            if(result){
                [results addObject:result];
            }
        }
        
        StrongObj(self)
        if(self){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self gkDismissLoadingToast];
                !self.photosOptions.completion ?: self.photosOptions.completion(results);
                
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    });
}

// MARK: - 操作

///是否选中asset
- (BOOL)containAsset:(PHAsset*) asset
{
    for(PHAsset *selectedAsset in self.selectedAssets){
        if([selectedAsset.localIdentifier isEqualToString:asset.localIdentifier]){
            return YES;
        }
    }
    return NO;
}

///删除某个asset
- (void)removeAsset:(PHAsset*) asset
{
    for(NSInteger i = 0;i < self.selectedAssets.count;i ++){
        PHAsset *selectedAsset = self.selectedAssets[i];
        if([selectedAsset.localIdentifier isEqualToString:asset.localIdentifier]){
            [self.selectedAssets removeObjectAtIndex:i];
            break;
        }
    }
}

///获取某个asset的下标
- (NSInteger)indexOfAsset:(PHAsset*) asset
{
    for(NSInteger i = 0;i < self.selectedAssets.count;i ++){
        PHAsset *selectedAsset = self.selectedAssets[i];
        if([selectedAsset.localIdentifier isEqualToString:asset.localIdentifier]){
            return i;
        }
    }
    
    return NSNotFound;
}

///当前下标
- (NSInteger)selectedIndex
{
    return floor(MAX(0, self.collectionView.contentOffset.x) / UIScreen.gkWidth);
}

///更新标题
- (void)updateTitle
{
    self.titleLabel.text = [NSString stringWithFormat:@"%d/%d", (int)(self.selectedIndex + 1), (int)self.assets.count];
    PHAsset *asset = self.assets[self.selectedIndex];
    if([self containAsset:asset]){
        self.checkBox.checkedText = [NSString stringWithFormat:@"%d", (int)[self indexOfAsset:asset] + 1];
        self.checkBox.checked = YES;
    }else{
        self.checkBox.checked = NO;
    }
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self updateTitle];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateTitle];
}

// MARK: - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = collectionView.frame.size;
    size.width -= self.imageSpacing;
    return size;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKPhotosPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GKPhotosPreviewCell class]) forIndexPath:indexPath];
    
    cell.loading = YES;
    cell.delegate = self;
    
    PHAsset *asset = self.assets[indexPath.item];
    cell.asset = asset;
    
    CGSize size = [UIImage gkFitImageSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) size:CGSizeMake(collectionView.frame.size.width * self.photosOptions.scale, 0) type:GKImageFitTypeWidth];
    [PHImageManager.defaultManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:self.requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if([asset.localIdentifier isEqualToString:cell.asset.localIdentifier]){
            [cell onLoadImage:result];
        }
    }];
    
    return cell;
}

- (void)photosPreviewCellDidClick:(GKPhotosPreviewCell *)cell
{
    [self setToolBarAndHeaderHidden:!self.photosToolBar.hidden];
}

@end
