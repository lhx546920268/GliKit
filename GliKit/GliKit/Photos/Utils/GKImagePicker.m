//
//  GKImagePicker.m
//  ZegoKit
//
//  Created by 罗海雄 on 2019/5/24.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKImagePicker.h"
#import "GKPhotosViewController.h"
#import "GKAlertUtils.h"
#import "GKAppUtils.h"
#import "GKFileManager.h"
#import "UIImage+GKUtils.h"
#import "GKPhotosOptions.h"
#import "GKImageCropViewController.h"
#import "GKImageCropSettings.h"
#import <AVFoundation/AVFoundation.h>
#import "GKAlertController.h"
#import "UIViewController+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKDialog.h"
#import "UIViewController+GKLoading.h"

@interface GKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

///图片回调
@property(nonatomic, copy) GKImagePickerCompletionHandler completionHandler;

///关联的
@property(nonatomic, weak) UIViewController *viewController;

///是否已调用
@property(nonatomic, assign) BOOL hasPicker;

@end

@implementation GKImagePicker

- (instancetype)initWithController:(UIViewController*) viewController
{
    self = [super init];
    if(self){
        self.viewController = viewController;
        _options = [GKPhotosOptions new];
        WeakObj(self)
        _options.completion = ^(NSArray<GKPhotosPickResult *> *results) {
            !selfWeak.completionHandler ?: selfWeak.completionHandler(results);
        };
    }
    
    return self;
}

- (void)pickImageWithCompletionHanler:(GKImagePickerCompletionHandler) handler
{
    self.completionHandler = handler;
    
    if(self.hasPicker)
        return;
    
    self.hasPicker = YES;
    WeakObj(self)
    GKAlertController *alert = [GKAlertUtils showActionSheetWithTitle:@"选择图片" message:nil icon:nil buttonTitles:@[@"拍照", @"相册"] cancelButtonTitle:@"取消" handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
        
        switch (buttonIndex) {
            case 0 : {
                [selfWeak camera];
            }
                break;
            case 1 : {
                [selfWeak album];
            }
                break;
            default:
                break;
        }
    }];
    alert.dialogDismissCompletionHandler = ^{
        selfWeak.hasPicker = NO;
    };
}

// MARK: - 拍照

+ (BOOL)canUseCamera
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [GKAlertUtils showAlertWithTitle:@"提示" message:@"相机不可用" icon:nil buttonTitles:@[@"确定"] destructiveButtonIndex:NSNotFound handler:nil];
        return NO;
    }else{
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
            NSString *msg = [NSString stringWithFormat:@"无法使用您的相机，请在本机的“设置-隐私-相机”中设置,允许%@使用您的相机", GKAppUtils.appName];
            [GKAlertUtils showAlertWithTitle:@"提示" message:msg icon:nil buttonTitles:@[@"取消", @"去设置"] destructiveButtonIndex:NSNotFound handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
                if(buttonIndex == 1){
                    [GKAppUtils openSettings];
                }
            }];
            
            return NO;
        }
    }
    
    return YES;
}

///拍照
- (void)camera
{
    if([GKImagePicker canUseCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    __block UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(image){
        [self.viewController gkShowLoadingToastWithText:nil];
        
        WeakObj(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            image = [UIImage gkFixOrientation:image];
            StrongObj(self)
            if(self){
                if(self.options.cropSettings){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.viewController gkDismissLoadingToast];
                        self.options.cropSettings.image = image;
                        GKImageCropViewController *imageCrop = [[GKImageCropViewController alloc] initWithOptions:self.options];
                        [self.viewController.navigationController pushViewController:imageCrop animated:YES];
                    });
                    
                }else{
                    GKPhotosPickResult *result = [GKPhotosPickResult resultWithImage:image options:self.options];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.viewController gkDismissLoadingToast];
                        if(result){
                            !self.completionHandler ?: self.completionHandler(@[result]);
                        }
                    });
                }
            }
        });
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - 相册

- (void)album
{
    //点击添加图片
    GKPhotosViewController *vc = [GKPhotosViewController new];
    vc.photosOptions = self.options;
    //避免有缓存时，在present过程中setViewControllers 导致导航栏的按钮和标题没有刷新的问题
    UINavigationController *nav = [vc gkCreateWithNavigationController];
    [vc loadViewIfNeeded];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}

@end
