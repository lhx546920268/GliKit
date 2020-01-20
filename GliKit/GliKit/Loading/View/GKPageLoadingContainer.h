//
//  GKPageLoadingContainer.h
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///状态
typedef NS_ENUM(NSInteger, GKPageLoadingStatus){
    
    ///加载中
    GKPageLoadingStatusLoading,
    
    ///加载出错了
    GKPageLoadingStatusError,
};

///页面加载显示容器代理
@protocol GKPageLoadingContainer <NSObject>

///设置是否是加载中
@property(nonatomic, assign) GKPageLoadingStatus status;

///刷新回调
@property(nonatomic, copy, nullable) void(^refreshHandler)(void);

///开始动画
- (void)startAnimating;

///停止动画
- (void)stopAnimating;

@end

///页面加载显示的容器
@interface GKPageLoadingContainer : UIView<GKPageLoadingContainer>

@end


NS_ASSUME_NONNULL_END
