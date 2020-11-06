//
//  GKScanViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKScanViewController.h"
#import "GKScanBackgroundView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIScreen+GKUtils.h"
#import "GKAlertUtils.h"
#import "GKAppUtils.h"
#import "GKBaseDefines.h"
#import "UIView+GKUtils.h"
#import <SDWebImage/SDWebImageDefine.h>
#import "UIViewController+GKUtils.h"
#import "GKImageCropSettings.h"
#import "GKPhotosViewController.h"
#import "UIViewController+GKLoading.h"

@interface GKScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

///二维码扫描背景
@property (nonatomic, strong) GKScanBackgroundView *scanBackgroundView;

///摄像头调用会话
@property (nonatomic, strong) AVCaptureSession *session;

///摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput *input;

///摄像头输出
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

///摄像头图像预览
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

///解码队列
@property (nonatomic, strong) dispatch_queue_t decodeQueue;

///后置摄像头
@property(nonatomic, readonly) AVCaptureDevice *backFacingCamera;

@end

@implementation GKScanViewController

@synthesize backFacingCamera = _backFacingCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"扫码";
        self.shouldRectOfInterest = YES;
        self.supportedTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startScan];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopScan];
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.captureVideoPreviewLayer.frame = self.scanBackgroundView.frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    //添加二维码扫描背景
    _scanBackgroundView = GKScanBackgroundView.new;
    
    WeakObj(self)
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || !self.backFacingCamera){
        //检测摄像头是否可用
        [self onCaptureDeviceUnavailable];
    }else{
        //检测摄像头授权状态
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined : {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    //可能不在主线程
                    dispatch_main_async_safe(^{
                        if(granted){
                            [selfWeak setupSession];
                        }else{
                            [selfWeak onAuthorizationDenied];
                        }
                    })
                }];
            }
                break;
            case AVAuthorizationStatusDenied :
            case AVAuthorizationStatusRestricted : {
                [self onAuthorizationDenied];
            }
            case AVAuthorizationStatusAuthorized : {
                [self setupSession];
            }
                break;
        }
    }

    _scanBackgroundView.scanBoxRectDidChange = ^(CGRect rect) {
        [selfWeak setRectOfInterest];
    };
    self.contentView = _scanBackgroundView;
}

// MARK: - Public

- (void)onAuthorizationDenied
{
    [GKAlertUtils showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"无法使用您的相机，请在本机的“设置-隐私-相机”中设置,允许%@使用您的相机", GKAppUtils.appName] icon:nil buttonTitles:@[@"取消", @"去设置"] destructiveButtonIndex:NSNotFound handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
       
        if(buttonIndex == 1){
            [GKAppUtils openSettings];
        }
    }];
}

- (void)onCaptureDeviceUnavailable
{
    [GKAlertUtils showAlertWithTitle:@"提示" message:@"摄像头不可用" icon:nil buttonTitles:@[@"确定"] destructiveButtonIndex:NSNotFound handler:nil];
}

- (void)startScan
{
    if(!self.pausing && self.session && !self.session.isRunning){
        [_scanBackgroundView startAnimating];
        [self.session startRunning];
    }
}

- (void)stopScan
{
    if(self.session.isRunning){
        [_scanBackgroundView stopAnimating];
        [self.session stopRunning];
    }
}

- (void)setPausing:(BOOL)pausing
{
    if(_pausing != pausing){
        _pausing = pausing;
        if(_pausing){
            [self stopScan];
        }else{
            [self startScan];
        }
    }
}

// MARK: - 相册

- (void)openPhotos
{
    //点击添加图片
    GKPhotosViewController *vc = [GKPhotosViewController new];
    vc.photosOptions.intention = GKPhotosIntentionSingleSelection;
    vc.photosOptions.needOriginalImage = YES;
    vc.photosOptions.compressedImageSize = CGSizeZero;
    WeakObj(self)
    vc.photosOptions.completion = ^(NSArray<GKPhotosPickResult *> * _Nonnull results) {
        [selfWeak detectBarCodeFromImage:results.firstObject.originalImage];
    };
    [self presentViewController:vc.gkCreateWithNavigationController animated:YES completion:nil];
}

///识别图片中的二维码
- (void)detectBarCodeFromImage:(UIImage*) image
{
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:options];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count == 0) {
        [self onDetectFail];
    } else {
        CIQRCodeFeature *feature = features.firstObject;
        [self processResult:feature.messageString];
    }
}

- (void)onDetectFail
{
    [self gkShowErrorWithText:@"图片识别失败"];
}

// MARK: - 二维码扫描设置

- (void)setLampOpen:(BOOL)open
{
    AVCaptureDevice *device = [self backFacingCamera];
    
    if(device.hasTorch){
        
        [device lockForConfiguration:nil];
        if(open){
            device.torchMode = AVCaptureTorchModeOn;
        }else{
            device.torchMode = AVCaptureTorchModeOff;
        }
        [device unlockForConfiguration];
    }
}

//通过摄像头位置，获取可用的摄像头
- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices;
    if(@available(iOS 10, *)) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        devices = discoverySession.devices;
    } else {
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//获取后置摄像头
- (AVCaptureDevice*)backFacingCamera
{
    if(_backFacingCamera == nil){
        _backFacingCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    return _backFacingCamera;
}

//二维码扫描摄像头设置
- (void)setupSession
{
    //初始化摄像头信息采集
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    self.output = [[AVCaptureMetadataOutput alloc] init];

    self.decodeQueue = dispatch_queue_create("com.glikit.scanDecode", NULL);
    [self.output setMetadataObjectsDelegate:self queue:self.decodeQueue];
    
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    //设置可扫描的类型
    NSArray *supportedTypes = self.supportedTypes;
    NSMutableArray *availableTypes = [NSMutableArray arrayWithCapacity:supportedTypes.count];
    NSArray *availableMetadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    for(NSString *type in supportedTypes){
        if([availableMetadataObjectTypes containsObject:type]){
            [availableTypes addObject:type];
        }
    }
    self.output.metadataObjectTypes = availableTypes;
    [self setRectOfInterest];
    
    //要判断是否支持，否则会蹦
    if([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080]){
        [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }else if([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]){
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    //图像图层
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    captureVideoPreviewLayer.frame = self.scanBackgroundView.frame;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer = captureVideoPreviewLayer;
    [self.view.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    if(self.isDisplaying){
        [self startScan];
    }
}

///设置扫描区域
- (void)setRectOfInterest
{
    if(self.output && self.shouldRectOfInterest){
        
        CGRect rect = self.scanBackgroundView.scanBoxRect;
        CGFloat width = self.scanBackgroundView.gkWidth;
        CGFloat height = self.scanBackgroundView.gkHeight;
        
        //设置解析范围
        if(rect.size.width > 0 && rect.size.height > 0 && width > 0 && height > 0){

            CGRect rectOfInterest = CGRectMake(rect.origin.y / height, rect.origin.x / width, rect.size.height / height, rect.size.width / width);
            self.output.rectOfInterest = rectOfInterest;
        }else{
            self.output.rectOfInterest = CGRectMake(0, 0, 1, 1);
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

///判断类型
- (BOOL)isAVMetadataObjectAvailable:(AVMetadataObject*) obj
{
    return [self.supportedTypes containsObject:obj.type];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *object in metadataObjects){
        if([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            if([self isAVMetadataObjectAvailable:object]){
                AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject *)object;

                dispatch_main_async_safe((^(void){
                    
                    if(!self.pausing){
                        self.pausing = YES;
                        [self processResult:code.stringValue];
                    }
                }));
            }
        }
    }
}

///处理描结果
- (void)processResult:(NSString*) result
{
    if(self.scanCallback){
        self.scanCallback(result);
        [self gkBack];
    }else{
        [self onScanCode:result];
    }
}

- (void)onScanCode:(NSString *)code
{
    
}

@end
