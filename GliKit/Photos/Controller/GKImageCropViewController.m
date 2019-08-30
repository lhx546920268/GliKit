//
//  GKImageCropViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "UIImage+GKUtils.h"
#import "UIViewController+GKUtils.h"
#import "UIViewController+GKLoading.h"
#import "GKPhotosOptions.h"
#import "UIView+GKUtils.h"
#import "UIScreen+GKUtils.h"
#import "GKBaseDefines.h"
#import <SDWebImageCompat.h>
#import "GKPhotosGridViewController.h"

@interface GKImageCropViewController ()

/**
 图片相框
 */
@property (nonatomic, strong) UIImageView *showImgView;

/**
 图片裁剪的部分控制图层，不被裁剪的部分会覆盖黑色半透明
 */
@property (nonatomic, strong) UIView *overlayView;

/**
 裁剪框
 */
@property (nonatomic, strong) UIView *ratioView;

/**
 图片的起始位置大小
 */
@property (nonatomic, assign) CGRect oldFrame;

/**
 图片的可以放大的最大尺寸
 */
@property (nonatomic, assign) CGRect largeFrame;

/**
 当前图片位置大小
 */
@property (nonatomic, assign) CGRect latestFrame;

/**
 取消按钮
 */
@property (nonatomic, strong) UIButton *cancelButton;

/**
 确认按钮
 */
@property (nonatomic, strong) UIButton *confirmButton;

/**
 选项
 */
@property(nonatomic, strong) GKPhotosOptions *photosOptions;

@end

@implementation GKImageCropViewController

- (id)initWithOptions:(GKPhotosOptions *)options
{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.photosOptions = options;
    }
    return self;
}

//MARK: 加载视图

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigatonBarHidden:YES animate:NO];
    self.view.clipsToBounds = YES;
    self.title = @"裁剪图片";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initControlBtn];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self initialization];
}

//初始化视图
- (void)initialization
{
    if(self.showImgView)
        return;
    
    self.gkShowBackItem = NO;
    //显示图片
    UIImage *image = self.photosOptions.cropSettings.image;
    self.showImgView = [UIImageView new];
    self.showImgView.multipleTouchEnabled = YES;
    self.showImgView.userInteractionEnabled = YES;
    self.showImgView.image = image;
    
    CGRect cropFrame = self.cropFrame;
    
    //把图片适配屏幕
    CGFloat width = MIN(self.view.gkWidth, image.size.width);
    CGFloat height = image.size.height * (width / image.size.width);
    
    
    if(self.photosOptions.cropSettings.useFullScreenCropFrame){
        if(width < cropFrame.size.width || height < cropFrame.size.height){
            CGFloat scale = MAX(cropFrame.size.width / width, cropFrame.size.height / height);
            width *= scale;
            height *= scale;
        }
    }
    
    CGFloat x = cropFrame.origin.x + (cropFrame.size.width - width) / 2;
    CGFloat y = cropFrame.origin.y + (cropFrame.size.height - height) / 2;
    
    self.oldFrame = CGRectMake(x, y, width, height);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.photosOptions.cropSettings.limitRatio * self.oldFrame.size.width, self.photosOptions.cropSettings.limitRatio * self.oldFrame.size.height);
    
    //添加捏合缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    //添加平移手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [self.view addSubview:self.showImgView];
    
    //裁剪区分图层
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = .5f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = NO;
    [self.view addSubview:self.overlayView];
    
    //编辑框
    self.ratioView = [[UIView alloc] initWithFrame:cropFrame];
    self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.layer.cornerRadius = self.photosOptions.cropSettings.cropCornerRadius;
    self.ratioView.layer.masksToBounds = YES;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    self.ratioView.userInteractionEnabled = NO;
    [self.view addSubview:self.ratioView];
    
    //
    [self overlayClipping];
}

///裁剪框大小
- (CGSize)cropSize
{
    CGSize cropSize = self.photosOptions.cropSettings.cropSize;
    if(self.photosOptions.cropSettings.useFullScreenCropFrame){
        cropSize = CGSizeMake(self.view.gkWidth, self.view.gkWidth * cropSize.height / cropSize.width);
        self.photosOptions.cropSettings.cropCornerRadius *= cropSize.width / self.photosOptions.cropSettings.cropSize.width;
    }
    
    return cropSize;
}

///裁剪范围
- (CGRect)cropFrame
{
    CGSize cropSize = [self cropSize];
    return CGRectMake((self.view.gkWidth - cropSize.width) / 2.0, (self.view.gkHeight - cropSize.height) / 2.0, cropSize.width, cropSize.height);
}

//初始化控制按钮
- (void)initControlBtn
{
    CGFloat buttonHeight = 50.0f;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - buttonHeight, UIScreen.gkScreenWidth, buttonHeight)];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:bgView];
    
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, buttonHeight)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [cancelBtn.titleLabel setNumberOfLines:0];
    [cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [cancelBtn addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelBtn];
    self.cancelButton = cancelBtn;
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100.0f, 0, 100, buttonHeight)];
    confirmBtn.backgroundColor = [UIColor clearColor];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn setTitle:@"使用" forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn.titleLabel setNumberOfLines:0];
    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [confirmBtn addTarget:self action:@selector(handleConfirm) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:confirmBtn];
    self.confirmButton = confirmBtn;
}

//MARK: private method

- (void)setShowProgress:(BOOL) show
{
    if(show){
        [self gkShowProgressWithText:nil];
    }else{
        [self gkDismissProgress];
    }
    self.navigationItem.leftBarButtonItem.enabled = !show;
    self.navigationItem.rightBarButtonItem.enabled = !show;
}

///取消
- (void)handleCancel
{
    [self gkBack];
}

///确认编辑
- (void)handleConfirm
{
    GKPhotosPickResult *result = [GKPhotosPickResult new];
    result.originalImage = [self cropImage];
    
    if(!CGSizeEqualToSize(CGSizeZero, self.photosOptions.compressedImageSize) || !CGSizeEqualToSize(CGSizeZero, self.photosOptions.thumbnailSize)){
        [self setShowProgress:YES];
        WeakObj(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            if(!CGSizeEqualToSize(CGSizeZero, selfWeak.photosOptions.compressedImageSize)){
                result.compressedImage = [result.originalImage gkAspectFitWithSize:selfWeak.photosOptions.compressedImageSize];;
            }
            
            if(!CGSizeEqualToSize(CGSizeZero, selfWeak.photosOptions.thumbnailSize)){
                result.thumbnail = [(result.compressedImage ? result.originalImage : result.originalImage) gkAspectFillWithSize:selfWeak.photosOptions.thumbnailSize];
            }
            
            [selfWeak onCropImage:result];
        });
    }else{
        [self onCropImage:result];
    }
}

///裁剪完成
- (void)onCropImage:(GKPhotosPickResult*) result
{
    dispatch_main_async_safe(^{
        [self setShowProgress:NO];
        !self.photosOptions.completion ?: self.photosOptions.completion(@[result]);
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        if(viewControllers.count >= 2){
            UIViewController *vc = [viewControllers objectAtIndex:viewControllers.count - 2];
            if([vc isKindOfClass:[GKPhotosGridViewController class]]){
                if(viewControllers.count > 3){
                    [self.navigationController popToViewController:[viewControllers objectAtIndex:viewControllers.count - 3] animated:YES];
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }else{
            [self handleCancel];
        }
    })
}

//绘制裁剪区分图层
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    if(self.photosOptions.cropSettings.cropCornerRadius == 0){
        //编辑框左边
        CGPathAddRect(path, NULL, CGRectMake(0, 0,
                                             self.ratioView.gkLeft,
                                             self.overlayView.gkHeight));
        //编辑框右边
        CGPathAddRect(path, NULL, CGRectMake(
                                             self.ratioView.gkLeft + self.ratioView.gkWidth,
                                             0,
                                             self.overlayView.gkWidth - self.ratioView.gkLeft - self.ratioView.gkWidth,
                                             self.overlayView.gkHeight));
        //编辑框上面
        CGPathAddRect(path, NULL, CGRectMake(0, 0,
                                             self.overlayView.gkWidth,
                                             self.ratioView.gkTop));
        //编辑框下面
        CGPathAddRect(path, NULL, CGRectMake(0,
                                             self.ratioView.gkTop + self.ratioView.gkHeight,
                                             self.overlayView.gkWidth,
                                             self.overlayView.gkHeight - self.ratioView.gkTop - self.ratioView.gkHeight));
    }else{
        CGPoint point1 = CGPointMake(0, self.ratioView.gkTop + self.ratioView.gkHeight / 2.0);
        CGPoint point2 = CGPointMake(self.ratioView.gkWidth, self.ratioView.gkTop + self.ratioView.gkHeight / 2.0);
        
        CGMutablePathRef path1 = CGPathCreateMutable();
        CGPathMoveToPoint(path1, NULL, point1.x, point1.y);
        CGPathAddLineToPoint(path1, NULL, 0, 0);
        CGPathAddLineToPoint(path1, NULL, self.ratioView.gkWidth, 0);
        CGPathAddLineToPoint(path1, NULL, point2.x, point2.y);
        CGPathAddArc(path1, NULL, self.ratioView.gkWidth / 2.0, point1.y, self.ratioView.gkWidth / 2.0, 0, M_PI, YES);
        
        CGPathAddPath(path, NULL, path1);
        
        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, NULL, point1.x, point1.y);
        CGPathAddLineToPoint(path2, NULL, 0, self.overlayView.gkHeight);
        CGPathAddLineToPoint(path2, NULL, self.ratioView.gkWidth, self.overlayView.gkHeight);
        CGPathAddLineToPoint(path2, NULL, point2.x, point2.y);
        CGPathAddArc(path2, NULL, self.ratioView.gkWidth / 2.0, point1.y, self.ratioView.gkWidth / 2.0, 0, M_PI, NO);
        
        CGPathAddPath(path, NULL, path2);
        
        CGPathRelease(path1);
        CGPathRelease(path2);
    }
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

//MARK: Gesture

//图片捏合缩放
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged){
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }else if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.25 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

//图片平移
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.25 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

//控制图片的缩放大小
- (CGRect)handleScaleOverflow:(CGRect)newFrame
{
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width / 2, newFrame.origin.y + newFrame.size.height / 2);
    if(newFrame.size.width < self.oldFrame.size.width){
        newFrame = self.oldFrame;
    }
    if(newFrame.size.width > self.largeFrame.size.width){
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width / 2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height / 2;
    return newFrame;
}

//控制平移的范围，不让图片超出编辑框
- (CGRect)handleBorderOverflow:(CGRect)newFrame
{
    //水平方向
    if(newFrame.origin.x > self.cropFrame.origin.x)
        newFrame.origin.x = self.cropFrame.origin.x;
    
    if(CGRectGetMaxX(newFrame) < self.cropFrame.origin.x + self.cropFrame.size.width)
        newFrame.origin.x = self.cropFrame.origin.x + self.cropFrame.size.width - newFrame.size.width;
    
    //垂直方向
    if(newFrame.origin.y > self.cropFrame.origin.y)
        newFrame.origin.y = self.cropFrame.origin.y;
    
    if(CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height)
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    
    //图片小于裁剪框 让图片居中
    if(newFrame.size.height <= self.cropFrame.size.height){
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    
    if(newFrame.size.width <= self.cropFrame.size.width){
        newFrame.origin.x = self.cropFrame.origin.x + (self.cropFrame.size.width - newFrame.size.width) / 2.0;
    }
    
    return newFrame;
}

//裁剪图片
- (UIImage*)cropImage
{
    //隐藏编辑框和控制按钮
    self.overlayView.hidden = YES;
    self.ratioView.hidden = YES;
    self.cancelButton.superview.hidden = YES;
    
    //如果图片小于编辑框，使用白色背景替代
    if(self.showImgView.gkWidth < self.cropFrame.size.width || self.showImgView.gkHeight < self.cropFrame.size.height){
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    //裁剪图片
    CGFloat height = self.view.gkHeight;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(UIScreen.gkScreenWidth, height), NO, 2.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    
    CGFloat scale = viewImage.scale;
    CGRect rect = CGRectMake(floor(self.cropFrame.origin.x * scale), floor(self.cropFrame.origin.y * scale), floor(self.cropFrame.size.width * scale), floor(self.cropFrame.size.height * scale));//这里可以设置想要截图的区域
    
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    CFRelease(imageRefRect);
    
    if(sendImage.size.width > self.photosOptions.cropSettings.cropSize.width){
        sendImage = [sendImage gkAspectFillWithSize:self.photosOptions.cropSettings.cropSize];
    }
    
    return sendImage;
}

@end
