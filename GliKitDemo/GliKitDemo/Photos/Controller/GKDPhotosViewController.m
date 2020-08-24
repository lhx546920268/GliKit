//
//  GKDPhotosViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDPhotosViewController.h"
#import <GKPhotosViewController.h>
#import "GKDPhotosCollectionViewCell.h"
#import <GKPhotosBrowseViewController.h>
#import <UIImageView+WebCache.h>

@interface GKDPhotosViewController ()

@property(nonatomic, strong) NSMutableArray<GKPhotosPickResult*> *results;
@property(nonatomic, strong) NSMutableArray<GKPhotosBrowseModel*> *models;

@property(nonatomic, assign) NSInteger maxCount;

@end

@implementation GKDPhotosViewController

+ (void)load
{
    [GKRouter.sharedRouter registerName:@"photo" forHandler:^UIViewController *(NSDictionary * _Nullable rounterParams) {
        
        GKDPhotosViewController *vc = [GKDPhotosViewController new];
        [vc setRouterParams:rounterParams];
        return vc;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.models = [NSMutableArray array];
    [self.models addObject:[GKPhotosBrowseModel modelWithURL:@"https://image.zegobird.com:10002/newupload/image/4c/e4/4ce4f167c552279be58ae86cdd86909207cec150efe34ebeae4bc686c4926d7f.jpg" thumnbailURL:@"https://image.zegobird.com:10002/newupload/image/4c/e4/4ce4f167c552279be58ae86cdd86909207cec150efe34ebeae4bc686c4926d7f.jpg@200w_200h"]];
    [self.models addObject:[GKPhotosBrowseModel modelWithURL:@"https://image.zegobird.com:10002/newupload/image/b0/30/b030dcb340d2985d7fe458e4626485abeb64ed3e996d4848a6a39533a80bf5bc.jpg" thumnbailURL:@"https://image.zegobird.com:10002/newupload/image/b0/30/b030dcb340d2985d7fe458e4626485abeb64ed3e996d4848a6a39533a80bf5bc.jpg@200w_200h"]];
    [self.models addObject:[GKPhotosBrowseModel modelWithURL:@"https://image.zegobird.com:10002/newupload/image/a3/73/a3739912fe1003a90d01d97a66cf8f4ef70f66e94d9f4c76931ecadc1df54aab.jpg" thumnbailURL:@"https://image.zegobird.com:10002/newupload/image/a3/73/a3739912fe1003a90d01d97a66cf8f4ef70f66e94d9f4c76931ecadc1df54aab.jpg@200w_200h"]];
    [self.models addObject:[GKPhotosBrowseModel modelWithURL:@"https://image.zegobird.com:10002/newupload/image/8a/2d/8a2d86e76b5726f2673cc155fd691a78eb638dac022247f1b9f72d68a7a0e0d6.jpg" thumnbailURL:@"https://image.zegobird.com:10002/newupload/image/8a/2d/8a2d86e76b5726f2673cc155fd691a78eb638dac022247f1b9f72d68a7a0e0d6.jpg@200w_200h"]];
    [self.models addObject:[GKPhotosBrowseModel modelWithURL:@"https://image.zegobird.com:10002/newupload/image/21/96/2196c3501c132d0da33b07b12ddb99cd63b13c0c056c4fd18d5b9b579379b679.jpg" thumnbailURL:@"https://image.zegobird.com:10002/newupload/image/21/96/2196c3501c132d0da33b07b12ddb99cd63b13c0c056c4fd18d5b9b579379b679.jpg@200w_200h"]];
    
    self.maxCount = 9;
    self.results = [NSMutableArray array];
    self.navigationItem.title = @"相册";
    [self initViews];
}

- (void)setRouterParams:(NSDictionary *)params
{
    self.photoName = [params gkStringForKey:@"name"];
    self.selectHandler = params[@"selectHandler"];
    
    self.navigationItem.title = self.photoName;
}

- (void)initViews
{
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    CGFloat size = floor((UIScreen.gkWidth - 15 * 2 - 5 * 2) / 3);
    self.flowLayout.itemSize = CGSizeMake(size, size);
    [self registerClass:GKDPhotosCollectionViewCell.class];
    [super initViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
//    return self.results.count >= self.maxCount ? self.results.count : self.results.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDPhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDPhotosCollectionViewCell.gkNameOfClass forIndexPath:indexPath];
    
//    if(indexPath.item < self.results.count){
//        cell.imageView.image = self.results[indexPath.item].thumbnail;
//    }else{
//        cell.imageView.image = [UIImage imageNamed:@"camera"];
//    }
    [cell.imageView sd_setImageWithURL:self.models[indexPath.item].thumbnailURL];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    !self.selectHandler ?: self.selectHandler(@"这是一个回调");
    
    GKPhotosBrowseViewController *controller = [[GKPhotosBrowseViewController alloc] initWithModels:self.models visibleIndex:indexPath.item];

    controller.animatedViewHandler = ^UIView*(NSUInteger index){

        GKDPhotosCollectionViewCell *cell = (GKDPhotosCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];

        return cell.imageView;
    };

    [controller showAnimated:YES];

    
//    if(indexPath.item < self.results.count){
//
//        NSMutableArray *images = [NSMutableArray array];
//        for(GKPhotosPickResult *result in self.results){
//            [images addObject:result.compressedImage];
//        }
//
//        GKPhotosBrowseViewController *controller = [[GKPhotosBrowseViewController alloc] initWithImages:images visibleIndex:indexPath.item];
//
//        controller.animatedViewHandler = ^UIView*(NSUInteger index){
//
//            GKDPhotosCollectionViewCell *cell = (GKDPhotosCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//
//            return cell.imageView;
//        };
//
//        [controller showAnimated:YES];
//
//    }else{
//        GKPhotosViewController *album = [GKPhotosViewController new];
//        album.photosOptions.maxCount = self.maxCount - self.results.count;
//        album.photosOptions.thumbnailSize = self.flowLayout.itemSize;
//        album.photosOptions.intention = GKPhotosIntentionMultiSelection;
////
////        GKImageCropSettings *settings = [GKImageCropSettings new];
////        settings.cropSize = CGSizeMake(200, 200);
////        album.photosOptions.cropSettings = settings;
//        album.photosOptions.needOriginalImage = YES;
//
//        WeakObj(self)
//        album.photosOptions.completion = ^(NSArray<GKPhotosPickResult *> *results) {
//            [selfWeak.results addObjectsFromArray:results];
//            [selfWeak.collectionView reloadData];
//        };
//
//        [self presentViewController:[album gkCreateWithNavigationController] animated:YES completion:nil];
//    }
    
    
}

@end
