//
//  GKToast.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///状态
typedef NS_ENUM(NSInteger, GKToastStatus){
    
    ///隐藏 什么都没
    GKToastStatusNone,
    
    ///加载中
    GKToastStatusLoading,
    
    ///提示错误信息
    GKToastStatusError,
    
    ///提示成功信息
    GKToastStatusSuccess,
    
    ///警告
    GKToastStatusWarning,
};

///加载指示器协议
@protocol GKToastProtocol <NSObject>

///提示信息
@property(nonatomic, copy, nullable) NSString *text;

///内容视图是否延迟显示 0 不延迟
@property(nonatomic, assign) NSTimeInterval delay;

///状态
@property(nonatomic, assign) GKToastStatus status;

///消失回调
@property(nonatomic, copy, nullable) void(^dismissCompletion)(void);

///显示
- (void)show;

///关闭 loading
- (void)dismissLoading;

///关闭所有
- (void)dismiss;

@end

///加载指示器 和 提示信息
@interface GKToast : UIView<GKToastProtocol>

///黑色半透明背景视图
@property(nonatomic, readonly) UIView *translucentView;

///提示信息
@property(nonatomic, readonly) UILabel *textLabel;

///加载指示器
@property(nonatomic, readonly, nullable) UIActivityIndicatorView *activityIndicatorView;

///提示图标
@property(nonatomic, readonly, nullable) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END


