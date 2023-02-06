//
//  CameraViewController.m
//  VideoDemo
//
//  Created by 罗海雄 on 2023/2/2.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import "PlayViewController.h"

@import Photos;

@interface CameraViewController ()

@property(nonatomic, strong) GPUImageVideoCamera *videoCamera;

///
@property(nonatomic, strong) GPUImageView *filterView;

///
@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;

///
@property(nonatomic, strong) NSMutableArray *videoPaths;

///
@property(nonatomic, strong) AVAssetExportSession *exportSession;

///
@property(nonatomic, strong) GPUImageBilateralFilter *filter;

///时间
@property(nonatomic, strong) UILabel *durationLabel;

///
@property(nonatomic, assign) NSTimeInterval duration;
@property (nonatomic,strong) NSTimer *videoTimer;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"录制视频";
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.videoPaths = [NSMutableArray array];
    
    //录制相关  AVCaptureSessionPreset1280x720视频分辨率 AVCaptureDevicePositionBack后置摄像头
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera = videoCamera;
    
    if ([videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [videoCamera.inputCamera unlockForConfiguration];
    }
    
    
    //输出方向为竖屏
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    [videoCamera addAudioInputsAndOutputs];
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    CGFloat totalHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat totalWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat topHeight = 0;//UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat bottomHeight = 80;
    if (@available(iOS 11, *)) {
        bottomHeight += UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
    }
    
    //显示view
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, topHeight, totalWidth, totalHeight - topHeight - bottomHeight)];
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView = filterView;
    [self.view addSubview:filterView];
    //组合
    //    filter = [[GPUImageBilateralFilter alloc] init];
    //    [videoCamera addTarget:filter];
    //    [filter addTarget:filterView];
    
    
    [videoCamera addTarget:filterView];
    //相机开始运行
    [videoCamera startCameraCapture];
    
    UIStackView *bottomView = [[UIStackView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(filterView.frame) + 20, totalWidth - 30, 60)];
    bottomView.axis = UILayoutConstraintAxisHorizontal;
    bottomView.distribution = UIStackViewDistributionEqualSpacing;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(handleBeauty:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"开启美颜" forState:UIControlStateNormal];
    [btn setTitle:@"关闭美颜" forState:UIControlStateSelected];
    [bottomView addArrangedSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(handleRotate) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"翻转摄像头" forState:UIControlStateNormal];
    [bottomView addArrangedSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(handlePress) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"长按录制" forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(20, 0, 20, 0);
    [bottomView addArrangedSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(handleComplete) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [bottomView addArrangedSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addTarget:self action:@selector(handleReset) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [bottomView addArrangedSubview:btn];
    [self.view addSubview:bottomView];
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake((totalWidth - 100) / 2, CGRectGetMaxY(filterView.frame), 100, 40)];
    self.durationLabel.font = [UIFont boldSystemFontOfSize:18];
    self.durationLabel.text = @"00:00";
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.durationLabel];
}

- (void)handleBeauty:(UIButton*) btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        
        // 移除之前所有的处理链
        [self.videoCamera removeAllTargets];
        
        // 创建美颜滤镜
        GPUImageBilateralFilter *filter = [[GPUImageBilateralFilter alloc] init];
        
        // 设置GPUImage处理链，从数据->滤镜->界面展示
        [self.videoCamera addTarget:filter];
        [filter addTarget:self.filterView];
        self.filter = filter;
        
    }else{
        
        // 移除之前所有的处理链
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.filterView];
        self.filter = nil;
    }
}

- (void)handleRotate
{
    [self.videoCamera rotateCamera];
}

- (void)handlePress
{
    NSLog(@"开始录制");
    [self initWriter];
    [self.videoTimer invalidate];
    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateDuration];
    }];
}

- (void)updateDuration
{
    long duration = self.duration + CMTimeGetSeconds(self.movieWriter.duration);
    long seconds = duration % 60;
    long minutes = duration / 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

- (void)handleCancel
{
    NSLog(@"结束录制");
    [self.movieWriter finishRecording];
    self.duration += CMTimeGetSeconds(self.movieWriter.duration);
    [self.videoCamera removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.videoTimer invalidate];
}

- (void)handleComplete
{
    if (self.videoPaths.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有视频数据" message:@"请录制视频" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    PlayViewController *vc = [PlayViewController new];
    vc.videoPaths = self.videoPaths;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
    [self handleReset];
}

- (void)handleReset
{
    [self.videoPaths removeAllObjects];
    self.duration = 0;
    self.durationLabel.text = @"00:00";
}

- (void)initWriter
{
    //    videoURL即视频文件的存储URL
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *videoPath = [paths.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970].stringValue]];
    if ([NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
        [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
    }
    [self.videoPaths addObject:videoPath];
    
    // 需要注意的是要调用unlink方法，否则写入可能会失败。
    //写入
    GPUImageMovieWriter *movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:videoPath] size:CGSizeMake(720.0, 1280.0)];
    self.movieWriter = movieWriter;
    
    //设置为liveVideo
    movieWriter.isNeedBreakAudioWhiter = YES;
    movieWriter.encodingLiveVideo = YES;
    movieWriter.shouldPassthroughAudio = YES;
    
    if (self.filter) {
        [self.filter addTarget:movieWriter];
    } else {
        [self.videoCamera addTarget:movieWriter];
    }
    //设置声音
    self.videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
}


@end
