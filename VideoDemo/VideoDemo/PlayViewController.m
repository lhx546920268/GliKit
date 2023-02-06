//
//  PlayViewController.m
//  VideoDemo
//
//  Created by 罗海雄 on 2023/2/2.
//

#import "PlayViewController.h"


@import AVFoundation;
@import AVKit;

@interface PlayViewController ()

///
@property(nonatomic, strong) AVAssetExportSession *exportSession;

///
@property(nonatomic, strong) UIView *loadingView;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(handleBack)];
    self.view.backgroundColor = UIColor.whiteColor;
    
    if (self.videoPaths.count <= 1) {
        [self playWithURL:[NSURL fileURLWithPath:self.videoPaths.firstObject]];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width - 100) / 2, (UIScreen.mainScreen.bounds.size.height - 80) / 2, 100, 80)];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.color = UIColor.grayColor;
        [view addSubview:indicatorView];
        [indicatorView startAnimating];
        indicatorView.center = CGPointMake(50, 30);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 100, 30)];
        label.text = @"正在处理...";
        label.textColor = UIColor.grayColor;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        [self.view addSubview:view];
        self.loadingView = view;
        
        [self merge];
    }
}

- (void)handleBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)merge
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString *videoPath = [paths.firstObject stringByAppendingPathComponent:@"lixa.mp4"];
        if ([NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
            [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
        }
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime totalDuration = kCMTimeZero;
        for (int i = 0; i < self.videoPaths.count; i++) {
            
            NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
            
            AVURLAsset *asset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoPaths[i]] options:options];
            
            NSError *erroraudio = nil;
            
            //获取AVAsset中的音频 或者视频
            AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            //向通道内加入音频或者视频
            BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                          ofTrack:assetAudioTrack
                                           atTime:totalDuration
                                            error:&erroraudio];
            
            NSLog(@"erroraudio:%@%d",erroraudio,ba);
            
            NSError *errorVideo = nil;
            AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                          ofTrack:assetVideoTrack
                                           atTime:totalDuration
                                            error:&errorVideo];
            
            NSLog(@"errorVideo:%@%d",errorVideo,bl);
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
        }
        
        NSURL *mergeFileURL = [NSURL fileURLWithPath:videoPath];
        
        
        //输出
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        self.exportSession = exporter;
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        //因为exporter.progress不可以被监听 所以在这里可以开启定时器取 exporter的值查看进度
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"Export Status: %ld", self.exportSession.status);
                [self playWithURL:mergeFileURL];
    //            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    //                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mergeFileURL];
    //            } completionHandler:^(BOOL success, NSError * _Nullable error1) {
    //                if (success) {
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video Saved!" message:@"Saved to the camera roll." preferredStyle:UIAlertControllerStyleAlert];
    //                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    //                        [alertController addAction:ok];
    //                        [self presentViewController:alertController animated:YES completion:nil];
    //                    });
    //                } else if (error1) {
    //                    NSLog(@"error: %@", error1);
    //                }
    //            }];
            });
            
        }];
    });
}

- (void)playWithURL:(NSURL*) URL
{
    [self.loadingView removeFromSuperview];
    AVPlayer *player = [AVPlayer playerWithURL:URL];
    AVPlayerViewController *vc = [AVPlayerViewController new];
    vc.player = player;
    vc.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    
    CGFloat topHeight = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomHeight = 80;
    if (@available(iOS 11, *)) {
        bottomHeight += UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
    }
    
    vc.view.frame = CGRectMake(0, topHeight, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - topHeight - bottomHeight);
    
    [player play];
}

@end
