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

@interface GKDPhotosViewController ()

@property(nonatomic, strong) NSMutableArray<GKPhotosPickResult*> *results;

@property(nonatomic, assign) NSInteger maxCount;

@end

@implementation GKDPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maxCount = 9;
    self.results = [NSMutableArray array];
    self.navigationItem.title = @"相册";
    [self initViews];
}

- (void)initViews
{
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    CGFloat size = floor((UIScreen.gkScreenWidth - 15 * 2 - 5 * 2) / 3);
    self.flowLayout.itemSize = CGSizeMake(size, size);
    [self registerClass:GKDPhotosCollectionViewCell.class];
    [super initViews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.results.count >= self.maxCount ? self.results.count : self.results.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKDPhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKDPhotosCollectionViewCell.gkNameOfClass forIndexPath:indexPath];
    
    if(indexPath.item < self.results.count){
        cell.imageView.image = self.results[indexPath.item].thumbnail;
    }else{
        cell.imageView.image = [UIImage imageNamed:@"camera"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if(indexPath.item < self.results.count){
        
        NSMutableArray *images = [NSMutableArray array];
        for(GKPhotosPickResult *result in self.results){
            [images addObject:result.compressedImage];
        }
        
//        SeaImageBrowseViewController *controller = [[SeaImageBrowseViewController alloc] initWithImages:images visibleIndex:indexPath.item];
//
//        controller.animatedViewHandler = ^UIView*(NSUInteger index){
//
//            PhotosPickerCollectionViewCell *cell = (PhotosPickerCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//
//            return cell;
//        };
//
//        [controller showAnimate:YES];
        
    }else{
        GKPhotosViewController *album = [GKPhotosViewController new];
        album.photosOptions.maxCount = self.maxCount - self.results.count;
        album.photosOptions.thumbnailSize = self.flowLayout.itemSize;
        album.photosOptions.intention = GKPhotosIntentionCrop;
        
        GKImageCropSettings *settings = [GKImageCropSettings new];
        settings.cropSize = CGSizeMake(200, 200);
        album.photosOptions.cropSettings = settings;
        album.photosOptions.needOriginalImage = YES;
        
        WeakObj(self)
        album.photosOptions.completion = ^(NSArray<GKPhotosPickResult *> *results) {
            [selfWeak.results addObjectsFromArray:results];
            [selfWeak.collectionView reloadData];
        };
        
        [self presentViewController:[album gkCreateWithNavigationController] animated:YES completion:nil];
    }
    
    
}

@end
