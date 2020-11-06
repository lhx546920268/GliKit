//
//  GKScanViewController.h
//  GliKit
//
//  Created by 罗海雄 on 2020/4/9.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKBaseViewController.h"
#import <AVFoundation/AVMetadataObject.h>

NS_ASSUME_NONNULL_BEGIN

///二维码扫描
@interface GKScanViewController : GKBaseViewController

///支持的扫码类型
@property(nonatomic, strong) NSArray<AVMetadataObjectType> *supportedTypes;

///扫描结果回调
@property(nonatomic, copy, nullable) void(^scanCallback)(NSString *result);

///是否正在暂停，暂停的时候无法开始
@property(nonatomic, assign) BOOL pausing;

///是否需要设置扫描区域，default YES，不设置时，即便二维码不在扫描框内也可以扫描成功
@property(nonatomic, assign) BOOL shouldRectOfInterest;

///没权限
- (void)onAuthorizationDenied;

///摄像头不可用
- (void)onCaptureDeviceUnavailable;

///设置开灯状态
- (void)setLampOpen:(BOOL) open;

///有结果了 会暂停扫描
- (void)onScanCode:(nullable NSString*) code;

///开始扫描
- (void)startScan;

///停止扫描
- (void)stopScan;

///打开相册扫描
- (void)openPhotos;

///相册图片识别失败
- (void)onDetectFail;

@end

NS_ASSUME_NONNULL_END
