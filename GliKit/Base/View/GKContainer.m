//
//  GKContainer.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 xiaozhai. All rights reserved.
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

@interface GKContainer()

///页面加载中
@property(nonatomic, strong) GKPageLoadingContainer *pageLoadingView;

@end

@implementation GKContainer

- (instancetype)initWithViewController:(GKBaseViewController*) viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialization];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
    }
    return self;
}

///初始化
- (void)initialization
{
    self.backgroundColor = [UIColor whiteColor];
    self.safeLayoutGuide = GKSafeLayoutGuideTop;
}

///布局的item
- (id)item
{
    return self.viewController ? self.viewController : self;
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

//MARK: topView

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
        
        _topView = topView;
        if(_topView){
            if(_topView.superview != self){
                [_topView removeFromSuperview];
                [self addSubview:_topView];
            }
            
            [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                    make.top.equalTo(self.viewController.gk_safeAreaLayoutGuideTop);
                }else{
                    make.top.equalTo(self.mas_top);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
                    make.leading.equalTo(self.viewController.gk_safeAreaLayoutGuideLeft);
                }else{
                    make.leading.equalTo(self.mas_leading);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
                    make.trailing.equalTo(self.viewController.gk_safeAreaLayoutGuideRight);
                }else{
                    make.trailing.equalTo(self.mas_trailing);
                }
                
                if(height != GKWrapContent){
                    make.height.equalTo(@(height));
                }
                
            }];
            
            if(self.contentView){
                
                self.contentView.gk_topLayoutConstraint.active = NO;
                [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.topView.mas_bottom);
                }];
            }
            
        }else{
            
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                    make.top.equalTo(self.viewController.gk_safeAreaLayoutGuideTop);
                }else{
                    make.top.equalTo(self.mas_top);
                }
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
    NSLayoutConstraint *constraint = self.topView.gk_bottomLayoutConstraint;
    if(constraint){
        if(!hidden){
            self.topView.hidden = hidden;
        }
        
        WeakObj(self);
        [UIView animateWithDuration:0.25 animations:^(void){
            
            constraint.constant = hidden ? 0 : -selfWeak.topViewOriginalHeight;
            [selfWeak layoutIfNeeded];
        } completion:^(BOOL finished){
            
            selfWeak.topView.hidden = hidden;
        }];
    }
}

//MARK: contentView


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
                if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
                    make.leading.equalTo(self.viewController.gk_safeAreaLayoutGuideLeft);
                }else{
                    make.leading.equalTo(self.mas_leading);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
                    make.trailing.equalTo(self.viewController.gk_safeAreaLayoutGuideRight);
                }else{
                    make.trailing.equalTo(self.mas_trailing);
                }
                
                if(self.topView){
                    make.top.equalTo(self.topView.mas_bottom);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                        make.top.equalTo(self.viewController.gk_safeAreaLayoutGuideTop);
                    }else{
                        make.top.equalTo(self.mas_top);
                    }
                }
                
                if(self.bottomView){
                    make.bottom.equalTo(self.bottomView.mas_top);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                        make.bottom.equalTo(self.viewController.gk_safeAreaLayoutGuideBottom);
                    }else{
                        make.bottom.equalTo(self.mas_bottom);
                    }
                }
            }];
        }
    }
}

//MARK: bottomView

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
        
        _bottomView = bottomView;
        if(_bottomView){
            if(_bottomView.superview != self){
                [_bottomView removeFromSuperview];
                [self addSubview:_bottomView];
            }
            
            [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                    make.bottom.equalTo(self.viewController.gk_safeAreaLayoutGuideBottom);
                }else{
                    make.bottom.equalTo(self.mas_bottom);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
                    make.leading.equalTo(self.viewController.gk_safeAreaLayoutGuideLeft);
                }else{
                    make.leading.equalTo(self.mas_leading);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
                    make.trailing.equalTo(self.viewController.gk_safeAreaLayoutGuideRight);
                }else{
                    make.trailing.equalTo(self.mas_trailing);
                }
                
                if(height != GKWrapContent){
                    make.height.equalTo(@(height));
                }
                
            }];
            
            if(self.contentView){
                self.contentView.gk_bottomLayoutConstraint.active = NO;
                [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.bottomView.mas_top);
                }];
            }
            
        }else{
            
            [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                    make.bottom.equalTo(self.viewController.gk_safeAreaLayoutGuideBottom);
                }else{
                    make.bottom.equalTo(self.mas_bottom);
                }
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
    NSLayoutConstraint *constraint = self.bottomView.gk_bottomLayoutConstraint;
    if(constraint){
        if(!hidden){
            self.bottomView.hidden = hidden;
        }
        
        WeakObj(self);
        [UIView animateWithDuration:0.25 animations:^(void){
            
            constraint.constant = !hidden ? 0 : -selfWeak.bottomViewOriginalHeight;
            [selfWeak layoutIfNeeded];
        } completion:^(BOOL finished){
            
            selfWeak.bottomView.hidden = hidden;
        }];
    }
}

//MARK: emptyView

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
                if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
                    make.leading.equalTo(self.viewController.gk_safeAreaLayoutGuideLeft);
                }else{
                    make.leading.equalTo(self);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
                    make.trailing.equalTo(self.viewController.gk_safeAreaLayoutGuideRight);
                }else{
                    make.trailing.equalTo(self);
                }
                
                if(self.topView && !(self.overlayArea & GKOverlayAreaEmptyViewTop)){
                    make.top.equalTo(self.topView.mas_bottom);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                        make.top.equalTo(self.viewController.gk_safeAreaLayoutGuideTop);
                    }else{
                        make.top.equalTo(self);
                    }
                }
                
                if(self.bottomView && !(self.overlayArea & GKOverlayAreaEmptyViewBottom)){
                    make.bottom.equalTo(self.bottomView.mas_top);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                        make.bottom.equalTo(self.viewController.gk_safeAreaLayoutGuideBottom);
                    }else{
                        make.bottom.equalTo(self);
                    }
                }
            }];
        }
    }
}

//MARK: page loading

- (GKPageLoadingContainer*)gkPageLoadingView
{
    return self.pageLoadingView;
}

- (void)setCa_pageLoadingView:(GKPageLoadingContainer*) gk_pageLoadingView
{
    if(gk_pageLoadingView == nil){
        [self.pageLoadingView removeFromSuperview];
        self.pageLoadingView = nil;
    }else{
        self.pageLoadingView = gk_pageLoadingView;
        if(!gk_pageLoadingView.superview){
            [self addSubview:gk_pageLoadingView];

            [gk_pageLoadingView makeConstraints:^(MASConstraintMaker *make) {
               
                if(self.safeLayoutGuide & GKSafeLayoutGuideLeft && self.viewController){
                    make.leading.equalTo(self.viewController.gk_safeAreaLayoutGuideLeft);
                }else{
                    make.leading.equalTo(self);
                }
                
                if(self.safeLayoutGuide & GKSafeLayoutGuideRight && self.viewController){
                    make.trailing.equalTo(self.viewController.gk_safeAreaLayoutGuideRight);
                }else{
                    make.trailing.equalTo(self);
                }
                
                if(self.topView && !(self.overlayArea & GKOverlayAreaPageLoadingTop)){
                    make.top.equalTo(self.topView.mas_bottom);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideTop && self.viewController){
                        make.top.equalTo(self.viewController.gk_safeAreaLayoutGuideTop);
                    }else{
                        make.top.equalTo(self);
                    }
                }
                
                if(self.bottomView && !(self.overlayArea & GKOverlayAreaPageLoadingBottom)){
                    make.bottom.equalTo(self.bottomView.mas_top);
                }else{
                    if(self.safeLayoutGuide & GKSafeLayoutGuideBottom && self.viewController){
                        make.bottom.equalTo(self.viewController.gk_safeAreaLayoutGuideBottom);
                    }else{
                        make.bottom.equalTo(self);
                    }
                }
            }];
        }
    }
}
@end
