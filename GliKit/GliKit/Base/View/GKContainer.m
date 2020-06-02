//
//  GKContainer.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKContainer.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "UIView+GKAutoLayout.h"
#import "UIView+GKEmptyView.h"
#import "GKPageLoadingContainer.h"
#import "UIView+GKLoading.h"
#import "GKNavigationBar.h"
#import "GKBaseViewController.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKUtils.h"

@interface GKContainer()

///页面加载中
@property(nonatomic, strong) UIView<GKPageLoadingContainer> *pageLoadingView;

@end

@implementation GKContainer

- (instancetype)initWithViewController:(GKBaseViewController*) viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
        [self initParams];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initParams];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initParams];
    }
    return self;
}

///初始化
- (void)initParams
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.safeLayoutGuide = GKSafeLayoutGuideTop;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    !self.layoutSubviewsHandler ?: self.layoutSubviewsHandler();
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    if(self.viewController.navigatonBar){
        [self.viewController.navigatonBar.superview bringSubviewToFront:self.viewController.navigatonBar];
    }
}

- (MASLayoutConstraint *)topLayoutConstraint
{
    if(_topView){
        return _topView.mas_bottom;
    }
    
    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
        return self.viewController.gkSafeAreaLayoutGuideTop;
    }else{
        return self.mas_top;
    }
}

- (MASLayoutConstraint *)bottomLayoutConstraint
{
    if(_bottomView){
        return _bottomView.mas_top;
    }
    
    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
        return self.viewController.gkSafeAreaLayoutGuideBottom;
    }else{
        return self.mas_bottom;
    }
}

- (CGFloat)bottomLayoutConstraintOffset
{
    if(!_bottomView && self.viewController.gkHasTabBar){
        return -self.viewController.gkTabBarHeight;
    }
    return 0;
}

- (MASLayoutConstraint *)leftLayoutConstraint
{
    if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
        return self.viewController.gkSafeAreaLayoutGuideLeft;
    }else{
        return self.mas_leading;
    }
}

- (MASLayoutConstraint *)rightLayoutConstraint
{
    if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
        return self.viewController.gkSafeAreaLayoutGuideRight;
    }else{
        return self.mas_trailing;
    }
}

// MARK: - topView

- (void)setTopView:(UIView *)topView
{
    [self setTopView:topView height:GKWrapContent];
}

- (void)setTopView:(UIView *)topView height:(CGFloat) height
{
    if(_topView != topView){
        
        if(_topView){
            [_topView removeFromSuperview];
        }
        _topView = nil;
        
        if(topView){
            if(topView.superview != self){
                [topView removeFromSuperview];
                [self addSubview:topView];
            }
            
            [topView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(self.topLayoutConstraint);
                make.leading.equalTo(self.leftLayoutConstraint);
                make.trailing.equalTo(self.rightLayoutConstraint);

                if(height != GKWrapContent){
                    make.height.equalTo(@(height));
                }
            }];
            
            if(self.contentView){
                
                self.contentView.gkTopLayoutConstraint.active = NO;
                [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.topView.mas_bottom);
                }];
            }
            _topView = topView;
        }else{
            
            self.contentView.gkTopLayoutConstraint.active = NO;
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.topLayoutConstraint);
            }];
        }
    }
}

- (CGFloat)topViewOriginalHeight
{
    if(_topView){
        [_topView layoutIfNeeded];
        return _topView.bounds.size.height;
    }
    return 0;
}

- (void)setTopViewHidden:(BOOL) hidden animate:(BOOL) animate
{
    NSLayoutConstraint *constraint = self.topView.gkBottomLayoutConstraint;
    if(constraint){
        if(!hidden){
            self.topView.hidden = hidden;
        }
        
        [UIView animateWithDuration:0.25 animations:^(void){
            
            constraint.constant = hidden ? 0 : -self.topViewOriginalHeight;
            [self layoutIfNeeded];
        } completion:^(BOOL finished){
            
            self.topView.hidden = hidden;
        }];
    }
}

// MARK: - contentView


- (void)setContentView:(UIView *)contentView
{
    if(_contentView != contentView){
        if(_contentView){
            [_contentView removeFromSuperview];
        }
        
        _contentView = contentView;
        if(_contentView){
            if(_contentView.superview != self){
                [_contentView removeFromSuperview];
                [self addSubview:_contentView];
            }
            
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.leftLayoutConstraint);
                make.trailing.equalTo(self.rightLayoutConstraint);
                make.top.equalTo(self.topLayoutConstraint);
                make.bottom.equalTo(self.bottomLayoutConstraint).offset(self.bottomLayoutConstraintOffset);
            }];
        }
    }
}

// MARK: - bottomView

- (void)setBottomView:(UIView *)bottomView
{
    [self setBottomView:bottomView height:GKWrapContent];
}

- (void)setBottomView:(UIView *)bottomView height:(CGFloat) height
{
    if(_bottomView != bottomView){
        
        if(_bottomView){
            [_bottomView removeFromSuperview];
        }
        
        _bottomView = nil;
        if(bottomView){
            if(bottomView.superview != self){
                [bottomView removeFromSuperview];
                [self addSubview:bottomView];
            }
            
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.leading.equalTo(self.leftLayoutConstraint);
                make.trailing.equalTo(self.rightLayoutConstraint);
                make.bottom.equalTo(self.bottomLayoutConstraint).offset(self.bottomLayoutConstraintOffset);
                
                if(height != GKWrapContent){
                    make.height.equalTo(@(height));
                }
                
            }];
            
            if(self.contentView){
                self.contentView.gkBottomLayoutConstraint.active = NO;
                [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.bottomView.mas_top);
                }];
            }
            _bottomView = bottomView;
        }else{
            
            self.contentView.gkBottomLayoutConstraint.active = NO;
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.bottomLayoutConstraint).offset(self.bottomLayoutConstraintOffset);
            }];
        }
    }
}

- (CGFloat)bottomViewOriginalHeight
{
    if(_bottomView){
        [_bottomView layoutIfNeeded];
        return _bottomView.bounds.size.height;
    }
    
    return 0;
}

- (void)setBottomViewHidden:(BOOL) hidden animate:(BOOL) animate
{
    NSLayoutConstraint *constraint = self.bottomView.gkBottomLayoutConstraint;
    if(constraint){
        if(!hidden){
            self.bottomView.hidden = hidden;
        }
        
        [UIView animateWithDuration:0.25 animations:^(void){
            
            constraint.constant = !hidden ? 0 : -self.bottomViewOriginalHeight;
            [self layoutIfNeeded];
        } completion:^(BOOL finished){
            
            self.bottomView.hidden = hidden;
        }];
    }
}

// MARK: - emptyView

- (void)layoutEmtpyView
{
    if(self.gkShowEmptyView){
        GKEmptyView *emptyView = self.gkEmptyView;
        if(emptyView != nil && emptyView.superview == nil){
            self.gkEmptyViewDelegate = (id<GKEmptyViewDelegate>)self.viewController;
            id<GKEmptyViewDelegate> delegate = self.gkEmptyViewDelegate;
            if([delegate respondsToSelector:@selector(emptyViewWillAppear:)]){
                [delegate emptyViewWillAppear:emptyView];
            }
            [self addSubview:emptyView];
            
            [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.leftLayoutConstraint);
                make.trailing.equalTo(self.rightLayoutConstraint);
                
                if(self.topView && !(self.overlayArea & GKOverlayAreaEmptyViewTop)){
                    make.top.equalTo(self.topView.mas_bottom);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                        make.top.equalTo(self.viewController.gkSafeAreaLayoutGuideTop);
                    }else{
                        make.top.equalTo(self);
                    }
                }
                
                if(self.bottomView && !(self.overlayArea & GKOverlayAreaEmptyViewBottom)){
                    make.bottom.equalTo(self.bottomView.mas_top);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                        make.bottom.equalTo(self.viewController.gkSafeAreaLayoutGuideBottom).offset(self.bottomLayoutConstraintOffset);
                    }else{
                        make.bottom.equalTo(self).offset(self.bottomLayoutConstraintOffset);
                    }
                }
            }];
        }
    }
}

// MARK: - page loading

- (UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    return self.pageLoadingView;
}

- (void)setGkPageLoadingView:(UIView<GKPageLoadingContainer> *)gkPageLoadingView
{
    if(gkPageLoadingView == nil){
        [self.pageLoadingView removeFromSuperview];
        self.pageLoadingView = nil;
    }else{
        self.pageLoadingView = gkPageLoadingView;
        if(!gkPageLoadingView.superview){
            [self addSubview:gkPageLoadingView];

            UIEdgeInsets insets = self.gkPageLoadingViewInsets;
            [gkPageLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.leading.equalTo(self.leftLayoutConstraint).offset(insets.left);
                make.trailing.equalTo(self.rightLayoutConstraint).offset(-insets.right);
                
                if(self.topView && !(self.overlayArea & GKOverlayAreaPageLoadingTop)){
                    make.top.equalTo(self.topView.mas_bottom).offset(insets.top);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                        make.top.equalTo(self.viewController.gkSafeAreaLayoutGuideTop).offset(insets.top);
                    }else{
                        make.top.equalTo(self).offset(insets.top);
                    }
                }
                
                if(self.bottomView && !(self.overlayArea & GKOverlayAreaPageLoadingBottom)){
                    make.bottom.equalTo(self.bottomView.mas_top).offset(-insets.bottom);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                        make.bottom.equalTo(self.viewController.gkSafeAreaLayoutGuideBottom).offset(-insets.bottom + self.bottomLayoutConstraintOffset);
                    }else{
                        make.bottom.equalTo(self).offset(-insets.bottom + self.bottomLayoutConstraintOffset);
                    }
                }
            }];
        }
    }
}
@end
