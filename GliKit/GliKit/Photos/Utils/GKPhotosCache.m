//
//  GKPhotosCache.m
//  GliKit
//
//  Created by 罗海雄 on 2023/1/10.
//  Copyright © 2023 luohaixiong. All rights reserved.
//

#import "GKPhotosCache.h"
#import <Photos/Photos.h>
#import "GKPhotosCollection.h"
#import "NSObject+GKUtils.h"
#import "GKBaseDefines.h"
#import "GKAppUtils.h"
#import "GKPhotosOptions.h"

@interface GKPhotosCache ()<PHPhotoLibraryChangeObserver>

///所有图片
@property(nonatomic, strong) PHFetchResult<PHAsset*> *allPhotos;

///智能相册
@property(nonatomic, strong) PHFetchResult<PHAssetCollection*> *smartAlbums;

///用户自定义相册
@property(nonatomic, strong) PHFetchResult<PHCollection*> *userAlbums;

///列表信息
@property(nonatomic, strong) NSMutableArray<GKPhotosCollection*> *datas;

///是否正在加载
@property(nonatomic, assign) BOOL loading;

///加载完成回调
@property(nonatomic, copy) CALoadPhotosCompletionHandler completionHandler;

///所有图片
@property(nonatomic, strong) GKPhotosCollection *allPhotosCollection;

///相册选项
@property(nonatomic, strong) GKPhotosOptions *photosOptions;

///相册资源获取选项
@property(nonatomic, strong) PHFetchOptions *fetchOptions;

@end

@implementation GKPhotosCache

+ (GKPhotosCache *)sharedCache
{
    static dispatch_once_t onceToken;
    static GKPhotosCache *sharedCache = nil;
    dispatch_once(&onceToken, ^{
        sharedCache = [GKPhotosCache new];
    });
    
    return sharedCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _clearWhenLowMemory = YES;
        _clearWhenEnterBackground = YES;
        
        _fetchOptions = [PHFetchOptions new];
        _fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

// MARK: - Load

///加载相册信息
- (void)loadPhotosWithOptions:(GKPhotosOptions *)options completionHandler:(CALoadPhotosCompletionHandler)completionHandler
{
    self.completionHandler = completionHandler;
    self.photosOptions = options;
    
    [GKAppUtils requestPhotosAuthorizationWithCompletion:^(BOOL hasAuth) {
        if(hasAuth){
            [self loadPhotos];
        }else{
            !completionHandler ?: completionHandler(nil);
            self.completionHandler = nil;
            self.photosOptions = nil;
        }
    }];

}

- (void)loadPhotos
{
    if (self.loading) {
        return;
    }
    
    if (self.allPhotosCollection || self.datas.count > 0) {
        [self onLoadPhotos];
    } else {
        self.loading = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            BOOL onlyAllPhotos = NO;
            if(@available(iOS 14, *)){
                onlyAllPhotos = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusLimited;
            }
            if(onlyAllPhotos){
                 self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.fetchOptions];
            }else{
                self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.fetchOptions];
                self.smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                self.userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            }
            
            [self generateDatas];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self onLoadPhotos];
            });
        });
    }
}

///生成列表数据
- (void)generateDatas
{
    NSMutableArray *datas = [NSMutableArray array];
    if(self.allPhotos.count > 0){
        GKPhotosCollection *photosCollection = [GKPhotosCollection new];
        BOOL onlyAllPhotos = NO;
        if(@available(iOS 14, *)){
            onlyAllPhotos = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusLimited;
        }
        if(onlyAllPhotos){
            photosCollection.title = @"可访问的图片";
        }else{
            photosCollection.title = @"所有图片";
        }
        photosCollection.assets = self.allPhotos;
        self.allPhotosCollection = photosCollection;
    }
    
    [self addAssetsFromColletions:self.smartAlbums withDatas:datas];
    [self addAssetsFromColletions:self.userAlbums withDatas:datas];
    
    self.datas = datas;
}

- (void)onLoadPhotos
{
    if (self.completionHandler) {
        NSMutableArray *datas = [NSMutableArray array];
        if (self.allPhotosCollection && self.photosOptions.shouldDisplayAllPhotos) {
            [datas addObject:self.allPhotosCollection];
        }
        
        for (GKPhotosCollection *collection in self.datas) {
            if (collection.assets.count > 0 || self.photosOptions.shouldDisplayEmptyCollection) {
                [datas addObject:collection];
            }
        }
        self.completionHandler(datas);
    }
    
    self.completionHandler = nil;
    self.photosOptions = nil;
}

///添加相册资源信息
- (void)addAssetsFromColletions:(PHFetchResult*) collections withDatas:(NSMutableArray*) datas
{
    for(PHAssetCollection *collection in collections){
        if([collection isKindOfClass:PHAssetCollection.class]){
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:self.fetchOptions];
            GKPhotosCollection *photosCollection = [GKPhotosCollection new];
            photosCollection.title = collection.localizedTitle;
            photosCollection.assets = result;
            [datas addObject:photosCollection];
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self clear];
}

// MARK: - Clear

- (void)clear
{
    self.allPhotosCollection = nil;
    self.datas = nil;
    self.allPhotos = nil;
    self.userAlbums = nil;
    self.smartAlbums = nil;
}

// MARK: - 通知

- (void)applicationDidEnterBackground:(NSNotification*) notification
{
    if (self.clearWhenEnterBackground) {
        [self clear];
    }
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification*) notification
{
    if (self.clearWhenLowMemory) {
        [self clear];
    }
}

@end
