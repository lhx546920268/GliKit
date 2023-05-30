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
#import <UIImageView+HighlightedWebCache.h>

@import AVFoundation;

@interface GKDPhotosViewController ()

@property(nonatomic, strong) NSMutableArray<GKPhotosPickResult*> *results;
@property(nonatomic, strong) NSMutableArray<GKPhotosBrowseModel*> *models;

@property(nonatomic, assign) NSInteger maxCount;

///
@property(nonatomic, strong) dispatch_queue_t videoQueue;
@property(nonatomic, strong) dispatch_queue_t audioQueue;
@property(nonatomic, strong) dispatch_group_t compressGroup;

@end

@implementation GKDPhotosViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"user/photo" forHandler:^UIViewController *(GKRouteConfig *config) {
        
        GKDPhotosViewController *vc = [GKDPhotosViewController new];
        return vc;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.compressGroup = dispatch_group_create();
    //必须串行队列
    self.videoQueue = dispatch_queue_create("com.lhx.video.compress", DISPATCH_QUEUE_SERIAL);
    self.audioQueue = dispatch_queue_create("com.lhx.audio.compress", DISPATCH_QUEUE_SERIAL);
   
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
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"zoo" withExtension:@"MOV"];
    [self compressVideoWithURL:url];
}

- (void)configRoute:(GKRouteConfig *)config
{
    self.photoName = [config.routeParams gkStringForKey:@"name"];
    self.selectHandler = config.routeParams[@"selectHandler"];
    
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

- (void)compressVideoWithURL:(NSURL*) URL
{
    AVAsset *asset = [AVAsset assetWithURL:URL];
//    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    
//    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"output.mp4"];
//    NSLog(@"%@", filePath);
//    if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
//        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
//    }
//
//    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
//    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeMPEG4 error:nil];
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSLog(@"size %@", NSStringFromCGSize(CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform)));
    NSLog(@"frameRate %f", videoTrack.nominalFrameRate);
    NSLog(@"bitRate %f", videoTrack.estimatedDataRate);
    
//    AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:[self videoOutputSettings]];
//    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self videoCompresSettings]];
//
//    if ([reader canAddOutput:videoOutput]) {
//        [reader addOutput:videoOutput];
//    }
//
//    if ([writer canAddInput:videoInput]) {
//        [writer addInput:videoInput];
//    }
//
//    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
//    AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:[self audioOutputSettings]];
//    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[self audioCompressSettings]];
//
//    if ([reader canAddOutput:audioOutput]) {
//        [reader addOutput:audioOutput];
//    }
//
//    if ([writer canAddInput:audioInput]) {
//        [writer addInput:audioInput];
//    }
//
//    [reader startReading];
//    [writer startWriting];
//    [writer startSessionAtSourceTime:kCMTimeZero];
//
//    dispatch_group_enter(self.compressGroup);
//
//    [videoInput requestMediaDataWhenReadyOnQueue:self.videoQueue usingBlock:^{
//        while (videoInput.isReadyForMoreMediaData) {
//            CMSampleBufferRef buffer = [videoOutput copyNextSampleBuffer];
//            if (buffer != NULL) {
//                BOOL result = [videoInput appendSampleBuffer:buffer];
////                NSLog(@"read video buffer size %zu", CMSampleBufferGetTotalSampleSize(buffer));
//                CFRelease(buffer);
//                if (!result) {
//                    NSLog(@"添加视频buffer失败");
//                    [reader cancelReading];
//                    break;
//                }
//            } else {
//                [videoInput markAsFinished];
//                dispatch_group_leave(self.compressGroup);
//                NSLog(@"读取视频结束了");
//                break;
//            }
//        }
//    }];
//
//    dispatch_group_enter(self.compressGroup);
//    [audioInput requestMediaDataWhenReadyOnQueue:self.audioQueue usingBlock:^{
//        while (audioInput.isReadyForMoreMediaData) {
//            CMSampleBufferRef buffer = [audioOutput copyNextSampleBuffer];
//            if (buffer != NULL) {
//                BOOL result = [audioInput appendSampleBuffer:buffer];
////                NSLog(@"read audio buffer size %zu", CMSampleBufferGetTotalSampleSize(buffer));
//                CFRelease(buffer);
//                if (!result) {
//                    NSLog(@"添加音频buffer失败");
//                    [reader cancelReading];
//                    break;
//                }
//            } else {
//                NSLog(@"读取音频结束了");
//                [audioInput markAsFinished];
//                dispatch_group_leave(self.compressGroup);
//                break;
//            }
//        }
//    }];
//
//    dispatch_group_notify(self.compressGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (reader.status == AVAssetReaderStatusReading) {
//            [reader cancelReading];
//        }
//
//        if (writer.status == AVAssetWriterStatusWriting) {
//            [writer finishWritingWithCompletionHandler:^{
//                NSLog(@"压缩完成");
//            }];
//        } else {
//            NSLog(@"压缩失败");
//        }
//    });
}

- (NSDictionary *)videoOutputSettings
{
    NSDictionary *outputSettings = @{
        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
        (__bridge NSString*)kCVPixelBufferIOSurfacePropertiesKey: @{}
    };
    
    return outputSettings;
}

- (NSDictionary*)videoCompresSettings
{
    NSDictionary *compressProps = @{
        AVVideoAverageBitRateKey: @(2000 * 1024),
        AVVideoExpectedSourceFrameRateKey: @30,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
    };
    
    NSDictionary *compressSettings = @{
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoWidthKey: @1080,
        AVVideoHeightKey: @608,
        AVVideoCompressionPropertiesKey: compressProps,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
    };
    
    return compressSettings;
}

- (NSDictionary *)audioOutputSettings
{
    return @{
        AVFormatIDKey: @(kAudioFormatLinearPCM)
    };
}

- (NSDictionary*)audioCompressSettings
{
    AudioChannelLayout layout = {
        .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
        .mChannelBitmap = 0,
        .mNumberChannelDescriptions = 0
    };
    
    NSData *data = [NSData dataWithBytes:&layout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    NSDictionary *compressSettings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVEncoderBitRateKey: @(128 * 1024),
        AVSampleRateKey: @44100,
        AVChannelLayoutKey: data,
        AVNumberOfChannelsKey: @2
    };
    
    return compressSettings;
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
  
    
//    GKDPhotosCollectionViewCell *cell = (GKDPhotosCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    //!self.selectHandler ?: self.selectHandler(@"这是一个回调");
    if(indexPath.item < self.models.count){

        GKPhotosBrowseViewController *controller = [[GKPhotosBrowseViewController alloc] initWithModels:self.models visibleIndex:indexPath.item];

        controller.animatedViewHandler = ^UIView*(NSUInteger index){

            GKDPhotosCollectionViewCell *cell = (GKDPhotosCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];

            return cell.imageView;
        };

        [controller showAnimated:YES];

    }else{
        GKPhotosViewController *album = [GKPhotosViewController new];
        album.photosOptions.maxCount = self.maxCount - self.results.count;
        album.photosOptions.thumbnailSize = self.flowLayout.itemSize;
        album.photosOptions.intention = GKPhotosIntentionMultiSelection;
//
//        GKImageCropSettings *settings = [GKImageCropSettings new];
//        settings.cropSize = CGSizeMake(200, 200);
//        album.photosOptions.cropSettings = settings;
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
