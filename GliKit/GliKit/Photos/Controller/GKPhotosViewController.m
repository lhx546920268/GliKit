//
//  GKPhotosViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKPhotosViewController.h"
#import <Photos/Photos.h>
#import "UIScrollView+GKEmptyView.h"
#import "UIViewController+GKUtils.h"
#import "GKPhotosCollection.h"
#import "GKPhotosListCell.h"
#import "NSObject+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "GKPhotosGridViewController.h"
#import "UIViewController+GKLoading.h"
#import "GKBaseDefines.h"
#import "GKAppUtils.h"
#import "UIApplication+GKTheme.h"
#import "GKPhotosCache.h"

@interface GKPhotosViewController ()

///列表信息
@property(nonatomic, strong) NSArray<GKPhotosCollection*> *datas;

///图片管理
@property(nonatomic, strong) PHCachingImageManager *imageManager;

///图片加载选项
@property(nonatomic, strong) PHImageRequestOptions *requestOptions;

@end

@implementation GKPhotosViewController

- (GKPhotosOptions *)photosOptions
{
    if(!_photosOptions){
        _photosOptions = [GKPhotosOptions new];
    }
    return _photosOptions;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.datas.count > 0 && !self.isInit){
        [self initViews];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.requestOptions = [PHImageRequestOptions new];
    self.requestOptions.networkAccessAllowed = YES;
    
    if(self.navigationController.presentingViewController || self.navigationController.viewControllers.firstObject == self){
        [self gkSetRightItemWithTitle:@"取消" action:@selector(handleCancel)];
    }
    
    self.navigationItem.title = @"相册";
    [self gkReloadData];
}

- (void)dealloc
{
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void)initViews
{
    //要授权才调用，否则在dealloc会闪退
    if(GKAppUtils.hasPhotosAuthorization){
        self.imageManager = [PHCachingImageManager new];
        self.imageManager.allowsCachingHighQualityImages = NO;
    }
    
    self.gkShowPageLoading = NO;
    [self registerClass:GKPhotosListCell.class];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 70;
    self.tableView.gkShouldShowEmptyView = YES;
    
    [super initViews];
}

// MARK: - action

///取消
- (void)handleCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - GKEmptyViewDelegate

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    NSString *msg = nil;
    if(!GKAppUtils.hasPhotosAuthorization){
        msg = [NSString stringWithFormat:@"无法访问您的照片，请在本机的“设置-隐私-照片”中设置,允许%@访问您的照片", GKAppUtils.appName];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettings)]];
    }else{
        msg = @"暂无照片信息";
    }
    view.textLabel.text = msg;
}

- (void)handleSettings
{
    [GKAppUtils openSettings];
}

// MARK: - load

- (void)gkReloadData
{
    [super gkReloadData];
    self.gkShowPageLoading = YES;
    [self loadPhotos];
}

///加载相册信息
- (void)loadPhotos
{
    WeakObj(self)
    [GKPhotosCache.sharedCache loadPhotosWithOptions:self.photosOptions completionHandler:^(NSArray<GKPhotosCollection *> * _Nullable collections) {
        selfWeak.datas = collections;
        [selfWeak onLoadPhotos];
    }];
}

///生成列表数据
- (void)onLoadPhotos
{
    if(self.isInit){
        [self.tableView reloadData];
    }
    
    if(self.photosOptions.displayFistCollection && self.datas.count > 0){
        GKPhotosGridViewController *vc = [GKPhotosGridViewController new];
        vc.photosOptions = self.photosOptions;
        vc.collection = self.datas.firstObject;
        
        [self.navigationController setViewControllers:@[self, vc]];
    }else{
        if(!self.isInit){
            [self initViews];
        }
    }
}

// MARK: - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKPhotosListCell *cell = [tableView dequeueReusableCellWithIdentifier:GKPhotosListCell.gkNameOfClass forIndexPath:indexPath];
    
    GKPhotosCollection *collection = self.datas[indexPath.row];
    cell.titleLabel.text = collection.title;
    cell.countLabel.text = [NSString stringWithFormat:@"(%d)", (int)collection.assets.count];
    
    if(collection.assets.count > 0){
        cell.thumbnailImageView.backgroundColor = UIColor.clearColor;
        cell.thumbnailImageView.image = nil;
        
        PHAsset *asset = collection.assets[0];
        cell.assetLocalIdentifier = asset.localIdentifier;
        
        [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeAspectFill options:self.requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if([asset.localIdentifier isEqualToString:cell.assetLocalIdentifier]){
                cell.thumbnailImageView.image = result;
                if(!result){
                    cell.thumbnailImageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                }else{
                    cell.thumbnailImageView.backgroundColor = UIColor.clearColor;
                }
            }
        }];
    }else{
        cell.thumbnailImageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        cell.thumbnailImageView.image = nil;
        cell.assetLocalIdentifier = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GKPhotosGridViewController *vc = [GKPhotosGridViewController new];
    vc.photosOptions = self.photosOptions;
    vc.collection = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
