//
//  GKPhotosGridViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosGridViewController.h"
#import "GKPhotosOptions.h"
#import "GKPhotosGridCell.h"
#import "GKPhotosCollection.h"
#import <Photos/Photos.h>
#import "GKPhotosCheckBox.h"
#import "GKAlertController.h"
#import "GKPhotosToolBar.h"
#import "GKPhotosPreviewViewController.h"
#import "GKContainer.h"
#import <ImageIO/ImageIO.h>
#import "UIViewController+GKUtils.h"
#import "UIScreen+GKUtils.h"
#import "UIViewController+GKLoading.h"
#import "GKBaseDefines.h"
#import "NSObject+GKUtils.h"
#import "UIViewController+GKTransition.h"
#import "GKImageCropViewController.h"
#import "UIImage+GKUtils.h"
#import "GKAppUtils.h"
#import "UIColor+GKTheme.h"

@interface GKPhotosGridViewController ()<GKPhotosGridCellDelegate>

//选中的图片
@property(nonatomic, strong) NSMutableArray<PHAsset*> *selectedAssets;

///图片管理
@property(nonatomic, strong) PHCachingImageManager *imageManager;

///上一个预缓存的区域
@property(nonatomic, assign) CGRect previousPrecachingRect;

///停止缓存的
@property(nonatomic, strong) NSMutableArray<PHAsset*> *stopCachingAssets;

///开始缓存的
@property(nonatomic, strong) NSMutableArray<PHAsset*> *startCachingAssets;

///底部工具条
@property(nonatomic, strong) GKPhotosToolBar *photosToolBar;

@end

@implementation GKPhotosGridViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateAssetCaches];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.isInit){
        [self.collectionView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.navigationController.presentingViewController){
        [self gkSetRightItemWithTitle:@"取消" action:@selector(handleCancel)];
    }
    
    //多选
    if(self.photosOptions.intention == GKPhotosIntentionMultiSelection){
        self.selectedAssets = [NSMutableArray arrayWithCapacity:self.photosOptions.maxCount];
    }
    
    self.navigationItem.title = self.collection.title;
    
    [self initViews];
}

- (void)dealloc
{
    [self.imageManager stopCachingImagesForAllAssets];
}


- (void)initViews
{
    UIView *bottomView = nil;
    UIButton *tipButton = nil;
    if(@available(iOS 14, *)){
        if([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusLimited){
            tipButton = [UIButton new];
            NSString *title = [NSString stringWithFormat:@"无法访问您的照片，请在本机的“设置-隐私-照片”中设置,允许%@访问您的照片", GKAppUtils.appName];
            [tipButton setTitle:title forState:UIControlStateNormal];
            [tipButton setTitleColor:UIColor.gkThemeTintColor forState:UIControlStateNormal];
            [tipButton setBackgroundColor:UIColor.gkThemeColor];
            tipButton.titleLabel.font = [UIFont systemFontOfSize:13];
            tipButton.titleLabel.numberOfLines = 0;
            tipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [tipButton addTarget:self action:@selector(handleSettings) forControlEvents:UIControlEventTouchUpInside];
            
            UIEdgeInsets insets = UIEdgeInsetsMake(15, 15, 15, 15);
            if(self.photosOptions.intention != GKPhotosIntentionMultiSelection){
                insets.bottom += UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
                bottomView = tipButton;
            }else{
                bottomView = [UIView new];
                [bottomView addSubview:tipButton];
                [tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.top.trailing.equalTo(0);
                }];
            }
            tipButton.contentEdgeInsets = insets;
        }
    }
    
    if(self.photosOptions.intention == GKPhotosIntentionMultiSelection){
        self.photosToolBar = [GKPhotosToolBar new];
        [self.photosToolBar.useButton addTarget:self action:@selector(handleUse) forControlEvents:UIControlEventTouchUpInside];
        [self.photosToolBar.previewButton addTarget:self action:@selector(handlePreview) forControlEvents:UIControlEventTouchUpInside];
        
        if(bottomView != nil){
            [bottomView addSubview:self.photosToolBar];
            [self.photosToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(0);
                make.top.equalTo(tipButton.mas_bottom);
            }];
            
        }else{
            bottomView = self.photosToolBar;
        }
    }
    
    [self setBottomView:bottomView];
    
    //要授权才调用，否则在dealloc会闪退
    if(GKAppUtils.hasPhotosAuthorization){
        self.imageManager = [PHCachingImageManager new];
        self.imageManager.allowsCachingHighQualityImages = NO;
    }
    
    CGFloat spacing = self.photosOptions.gridInterval;
    self.flowLayout.minimumLineSpacing = spacing;
    self.flowLayout.minimumInteritemSpacing = spacing;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    CGFloat size = floor((UIScreen.gkWidth - (self.photosOptions.numberOfItemsPerRow + 1) * spacing) / self.photosOptions.numberOfItemsPerRow);
    self.flowLayout.itemSize = CGSizeMake(size, size);
    
    [self registerClass:GKPhotosGridCell.class];
    
    self.collectionView.gkShouldShowEmptyView = YES;
    
    [super initViews];
    
    if(self.collection.assets.count > 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.collection.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

// MARK: - action

- (void)handleSettings
{
    [GKAppUtils openSettings];
}

///取消
- (void)handleCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///预览
- (void)handlePreview
{
    GKPhotosPreviewViewController *vc = [GKPhotosPreviewViewController new];
    vc.assets = [self.selectedAssets copy];
    vc.selectedAssets = self.selectedAssets;
    vc.photosOptions = self.photosOptions;
    [self.navigationController pushViewController:vc animated:YES];
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
        [self.imageManager requestImageDataForAsset:selectedAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
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
- (void)onImageDataLoad:(NSArray*) datas
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
                [self handleCancel];
            });
        }
    });
}

///裁剪图片
- (void)cropImageWithAsset:(PHAsset*) asset
{
    [self gkShowLoadingToastWithText:nil];
    self.gkBackBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    WeakObj(self)
    [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        StrongObj(self)
        if(self){
            self.gkBackBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            if(imageData){
                [self gkDismissLoadingToast];
                self.photosOptions.cropSettings.image = [UIImage imageWithData:imageData scale:self.photosOptions.scale];
                [self goToCropImage];
            }else{
                [self gkShowErrorWithText:@"加载图片失败"];
            }
        }
    }];
}

///跳转去图片裁剪界面
- (void)goToCropImage
{
    GKImageCropViewController *vc = [[GKImageCropViewController alloc] initWithOptions:self.photosOptions];
    [self.navigationController pushViewController:vc animated:YES];
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

// MARK: - GKEmptyViewDelegate

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    view.textLabel.text = @"暂无照片信息";
}

// MARK: - caching

///更新缓存
- (void)updateAssetCaches
{
    if(self.isViewLoaded && self.view.window && self.collection.assets.count > 0){
        
        if(!self.startCachingAssets){
            self.startCachingAssets = [NSMutableArray array];
        }
        if(!self.stopCachingAssets){
            self.stopCachingAssets = [NSMutableArray array];
        }
        
        CGSize size = self.collectionView.frame.size;
        CGRect visibleRect = {self.collectionView.contentOffset, size};
        CGRect precachingRect = CGRectInset(visibleRect, 0, - size.height / 2.0);
        
        //滑动距离太短
        if(fabs(CGRectGetMidY(precachingRect) - CGRectGetMidY(self.previousPrecachingRect)) < size.height / 3.0){
            return;
        }
        
        [self.stopCachingAssets removeAllObjects];
        [self.startCachingAssets removeAllObjects];
        
        CGRect stopCachingRect = self.previousPrecachingRect;
        CGRect startCachingRect = precachingRect;
        
        //两个区域相交，移除后面的，保留中间交叉的，添加前面的
        if(CGRectIntersectsRect(precachingRect, self.previousPrecachingRect)){
            
            if(self.previousPrecachingRect.origin.y < precachingRect.origin.y){
                //向下滑动
                stopCachingRect = CGRectMake(0, CGRectGetMinY(precachingRect), size.width, self.previousPrecachingRect.origin.y - precachingRect.origin.y);
                startCachingRect = CGRectMake(0, CGRectGetMaxY(self.previousPrecachingRect), size.width, CGRectGetMaxY(precachingRect) - CGRectGetMaxY(self.previousPrecachingRect));
            }else{
                //向上滑动
                stopCachingRect = CGRectMake(0, CGRectGetMaxY(precachingRect), size.width, CGRectGetMaxY(self.previousPrecachingRect) - CGRectGetMaxY(precachingRect));
                startCachingRect = CGRectMake(0, CGRectGetMinY(precachingRect), size.width, self.previousPrecachingRect.origin.y - precachingRect.origin.y);
            }
        }
        
        if(stopCachingRect.size.height > 0){
            NSArray *attrs = [self.flowLayout layoutAttributesForElementsInRect:stopCachingRect];
            for(UICollectionViewLayoutAttributes *attr in attrs){
                [self.stopCachingAssets addObject:self.collection.assets[attr.indexPath.item]];
            }
        }
        
        if(startCachingRect.size.height > 0){
            NSArray *attrs = [self.flowLayout layoutAttributesForElementsInRect:startCachingRect];
            for(UICollectionViewLayoutAttributes *attr in attrs){
                [self.startCachingAssets addObject:self.collection.assets[attr.indexPath.item]];
            }
        }
        
        if(self.stopCachingAssets.count > 0){
            [self.imageManager stopCachingImagesForAssets:self.stopCachingAssets targetSize:self.flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil];
        }
        
        if(self.startCachingAssets.count > 0){
            [self.imageManager startCachingImagesForAssets:self.startCachingAssets targetSize:self.flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil];
        }
        
        self.previousPrecachingRect = precachingRect;
    }
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateAssetCaches];
}

// MARK: - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collection.assets.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKPhotosGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKPhotosGridCell.gkNameOfClass forIndexPath:indexPath];
    
    PHAsset *asset = self.collection.assets[indexPath.item];
    if(self.photosOptions.intention == GKPhotosIntentionMultiSelection){
        cell.checkBox.hidden = NO;
        cell.checked = [self containAsset:asset];
        if(cell.checked){
            cell.checkBox.checkedText = [NSString stringWithFormat:@"%d", (int)[self indexOfAsset:asset ] + 1];
        }else{
            cell.checkBox.checkedText = nil;
        }
    }else{
        cell.checkBox.hidden = YES;
    }
    cell.delegate = self;
    cell.asset = asset;
    
    [self.imageManager requestImageForAsset:asset targetSize:self.flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if([asset.localIdentifier isEqualToString:cell.asset.localIdentifier]){
            cell.imageView.image = result;
            if(!result){
                cell.imageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            }else{
                cell.imageView.backgroundColor = UIColor.clearColor;
            }
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    switch (self.photosOptions.intention) {
        case GKPhotosIntentionMultiSelection : {
            
            NSMutableArray *assets = [NSMutableArray arrayWithCapacity:self.collection.assets.count];
            for(PHAsset *asset in self.collection.assets){
                [assets addObject:asset];
            }
            
            GKPhotosPreviewViewController *vc = [GKPhotosPreviewViewController new];
            vc.assets = assets;
            vc.selectedAssets = self.selectedAssets;
            vc.photosOptions = self.photosOptions;
            vc.visiableIndex = indexPath.item;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case GKPhotosIntentionCrop : {
            
            PHAsset *asset = self.collection.assets[indexPath.item];
            [self cropImageWithAsset:asset];
        }
            break;
        case GKPhotosIntentionSingleSelection : {
            
            [self useAssets:@[self.collection.assets[indexPath.item]]];
        }
            break;
        default:
            break;
    }
}

// MARK: - GKPhotosGridCellDelegate

- (void)photosGridCellCheckedDidChange:(GKPhotosGridCell *)cell
{
    if(cell.checked){
        cell.checked = NO;
        [self removeAsset:cell.asset];
        
        //reloadData 图片会抖动 所以只刷新选中下标
        NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
        for(NSIndexPath *indexPath in indexPaths){
            GKPhotosGridCell *cell = (GKPhotosGridCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            PHAsset *asset = self.collection.assets[indexPath.item];
            cell.checked = [self containAsset:asset];
            if(cell.checked){
                cell.checkBox.checkedText = [NSString stringWithFormat:@"%d", (int)[self indexOfAsset:asset] + 1];
            }else{
                cell.checkBox.checkedText = nil;
            }
        }
    }else{
        if(self.selectedAssets.count >= self.photosOptions.maxCount){
            
            [[GKAlertController alertWithTitle:[NSString stringWithFormat:@"您最多能选择%d张图片", (int)self.photosOptions.maxCount]
                                       message:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"我知道了"]] show];
            
        }else{
            [self.selectedAssets addObject:cell.asset];
            cell.checkBox.checkedText = [NSString stringWithFormat:@"%d", (int)self.selectedAssets.count];
            [cell setChecked:YES animated:YES];
        }
    }
    self.photosToolBar.count = (int)self.selectedAssets.count;
}

@end
