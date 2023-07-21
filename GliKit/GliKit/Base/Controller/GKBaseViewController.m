//
//  GKBaseViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewController.h"
#import "NSObject+GKUtils.h"
#import "GKContainer.h"
#import "UIViewController+GKKeyboard.h"
#import "GKBaseViewModel.h"
#import "GKNavigationBar.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "UIViewController+GKUtils.h"
#import "UIView+GKUtils.h"
#import "UIViewController+GKDialog.h"
#import "GKBaseDefines.h"
#import "UIApplication+GKTheme.h"
#import "UIImage+GKTheme.h"

@interface GKBaseViewController ()<UIGestureRecognizerDelegate>

///用来在delloc之前 要取消的请求
@property(nonatomic, strong) NSHashTable<id<GKCancelableTask>> *currentTasks;

///点击回收键盘手势
@property(nonatomic, strong) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;

///界面显示次数
@property(nonatomic, assign) NSInteger displayTimes;

@end

@implementation GKBaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.hidesBottomBarWhenPushed = YES;
        self.shouldCreateNavigationBar = YES;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.statusBarStyle = UIApplication.gkDarkStatusBarStyle;
    }
    return self;
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle
{
    return UIUserInterfaceStyleLight;
}

// MARK: - View Life Cycle

- (void)loadView
{
    //如果有 xib 则加载对应的xib
    if([NSBundle.mainBundle pathForResource:self.gkNameOfClass ofType:@"nib"]){
        self.view = [[[NSBundle mainBundle] loadNibNamed:self.gkNameOfClass owner:self options:nil] lastObject];
    }else{
        _container = [[GKContainer alloc] initWithViewController:self];
        if(!self.isShowAsDialog){
            self.view = self.container;
        }else{
            self.view = [UIView new];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.viewModel){
        [self.viewModel viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.viewModel){
        [self.viewModel viewDidAppear:animated];
    }
    _isDisplaying = YES;
    self.displayTimes ++;
    if(self.isFisrtDisplay){
        [self viewDidFirstAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.viewModel){
        [self.viewModel viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.viewModel){
        [self.viewModel viewDidDisappear:animated];
    }
    _isDisplaying = NO;
}

- (void)viewDidFirstAppear:(BOOL) animated
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //显示自定义导航栏
    if(self.shouldCreateNavigationBar && [self.parentViewController isKindOfClass:[UINavigationController class]]){
        _navigatonBar = [self.navigationBarClass new];
        _navigatonBar.title = self.title;
        [self.view addSubview:_navigatonBar];
        
        [_navigatonBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.height.mas_equalTo(self.gkStatusBarHeight + self.gkNavigationBarHeight);
        }];
    }
    
    if(self.isShowAsDialog){
        if(self.container){
            self.container.safeLayoutGuide = GKSafeLayoutGuideNone;
            
            //当 self.view 不是 container时， container中的子视图布局完成不会调用 viewDidLayoutSubviews 要手动，否则在 viewDidLayoutSubviews中获取 self.contentView的大小时会失败
            WeakObj(self);
            self.container.layoutSubviewsHandler = ^(void){
                [selfWeak viewDidLayoutSubviewsShouldCallSuper:NO];
            };
            [self.view addSubview:self.container];
        }
    }else{
        
        self.view.backgroundColor = [UIColor whiteColor];
        if(!self.showBackItem && (self.navigationController.viewControllers.count > 1 || self.navigationController.presentingViewController)){
            self.showBackItem = YES;
        }
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _navigatonBar.title = title;
}

- (BOOL)isFisrtDisplay
{
    return self.displayTimes <= 1;
}

- (void)viewDidLayoutSubviews
{
    [self viewDidLayoutSubviewsShouldCallSuper:YES];
}

- (void)viewDidLayoutSubviewsShouldCallSuper:(BOOL) callSuper
{
    if(callSuper){
        [super viewDidLayoutSubviews];
    }
    _isViewDidLayoutSubviews = YES;
    if(self.navigatonBar){
        [self.view bringSubviewToFront:self.navigatonBar];
        //不要挡住弹窗的
        if (self.childViewControllers.count > 0) {
            for (UIViewController *vc in self.childViewControllers) {
                if (vc.isShowAsDialog && vc.dialogShowAnimate == GKDialogAnimateFromBottom) {
                    [self.view bringSubviewToFront:vc.view];
                }
            }
        }
    }
}

// MARK: - 导航栏

- (Class)navigationBarClass
{
    return [GKNavigationBar class];
}

- (void)setNavigatonBarHidden:(BOOL)hidden animate:(BOOL)animate
{
    if(animate){
        if(!hidden){
            self.navigatonBar.hidden = hidden;
        }
        
        CGFloat height = self.gkStatusBarHeight + self.gkNavigationBarHeight;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        if(hidden){
            animation.fromValue = @(height / 2.0);
            animation.toValue = @(-height / 2.0);
        }else{
            animation.fromValue = @(-height / 2.0);
            animation.toValue = @(height / 2.0);
        }
        animation.duration = UINavigationControllerHideShowBarDuration;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.navigatonBar.layer addAnimation:animation forKey:@"position"];
    }else{
        self.navigatonBar.hidden = hidden;
        [self.navigatonBar.layer removeAnimationForKey:@"position"];
    }
}

- (void)setShowBackItem:(BOOL)showBackItem
{
    if (_showBackItem != showBackItem) {
        _showBackItem = showBackItem;
        if (_showBackItem) {
            UIImage *image = UIImage.gkNavigationBarBackIcon;
            NSAssert(image != nil, @"you must set UIImage.gkNavigationBarBackIcon");
            [self.navigatonBar setLeftItemWithImage:image target:self action:@selector(gkBack)];
        } else {
            self.navigatonBar.leftItemView = nil;
        }
    }
}

- (void)gkBack
{
    _isDisplaying = NO;
    _isBacked = YES;
    [super gkBack];
}

// MARK: - GKEmptyViewDelegate

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    view.iconImageView.image = [UIImage imageNamed:@"empty"];
    view.textLabel.text = @"暂无数据";
}

// MARK: - UIStatusBar

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    if(_statusBarStyle != statusBarStyle){
        _statusBarStyle = statusBarStyle;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

// MARK: - Task

- (NSHashTable *)currentTasks
{
    if(!_currentTasks){
        _currentTasks = [NSHashTable weakObjectsHashTable];
    }
    
    return _currentTasks;
}

- (void)addCancelableTask:(id<GKCancelableTask>)task
{
    [self addCancelableTask:task cancelTheSame:YES];
}

- (void)addCancelableTask:(id<GKCancelableTask>)task cancelTheSame:(BOOL)cancel
{
    if(cancel){
        [self cancelTaskforKey:task.taskKey];
    }
    if(task){
        [self.currentTasks addObject:task];
    }
}

///移除无效的请求
- (void)cancelTaskforKey:(NSString*) key
{
    for(id<GKCancelableTask> task in _currentTasks){
        if([task.taskKey isEqualToString:key]){
            [task cancel];
        }
    }
}

- (void)gkReloadData
{
    if(self.viewModel){
        [self.viewModel reloadData];
    }
}

- (void)onLoadData
{
    
}

- (void)dealloc
{
    //取消正在执行的请求
    for(id<GKCancelableTask> task in _currentTasks){
        [task cancel];
    }
}

// MARK: - 键盘

- (void)setShouldDismissKeyboardWhileTap:(BOOL)shouldDismissKeyboardWhileTap
{
    if(_shouldDismissKeyboardWhileTap != shouldDismissKeyboardWhileTap){
        _shouldDismissKeyboardWhileTap = shouldDismissKeyboardWhileTap;
        if(!self.dismissKeyboardGestureRecognizer){
            self.dismissKeyboardGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissKeyboard:)];
            self.dismissKeyboardGestureRecognizer.delegate = self;
            [self.view addGestureRecognizer:self.dismissKeyboardGestureRecognizer];
        }
        
        self.dismissKeyboardGestureRecognizer.enabled = _shouldDismissKeyboardWhileTap;
    }
}

///键盘高度改变
- (void)keyboardWillChangeFrame:(NSNotification*) notification
{
    [super keyboardWillChangeFrame:notification];
    
    ///弹出键盘，改变弹窗位置
    if(self.isShowAsDialog){
        [self adjustDialogPosition];
    }
}

///回收键盘
- (void)handleDismissKeyboard:(id) sender
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

// MARK: - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.dismissKeyboardGestureRecognizer) {
        return touch.view == self.view;
    }
    return YES;
}

@end

@implementation GKBaseViewController(GKContainerExtension)

- (void)setTopView:(UIView *)topView
{
    [_container setTopView:topView];
}

- (void)setTopView:(UIView *)topView height:(CGFloat)height
{
    [_container setTopView:topView height:height];
}

- (UIView*)topView
{
    return _container.topView;
}

- (void)setBottomView:(UIView *)bottomView
{
    [_container setBottomView:bottomView];
}

- (void)setBottomView:(UIView *)bottomView height:(CGFloat)height
{
    [_container setBottomView:bottomView height:height];
}

- (UIView*)bottomView
{
    return _container.bottomView;
}

- (void)setContentView:(UIView *)contentView
{
    [_container setContentView:contentView];
}

- (UIView*)contentView
{
    return _container.contentView;
}

@end

@implementation GKBaseViewController (GKNavigationBarItemExtension)

- (UIButton *)setLeftItemWithImage:(UIImage *)image action:(SEL)action
{
    return [self.navigatonBar setLeftItemWithImage:image target:self action:action];
}

- (UIButton *)setLeftItemWithTitle:(NSString *)title action:(SEL)action
{
    return [self.navigatonBar setLeftItemWithTitle:title target:self action:action];
}

- (UIButton *)setRightItemWithImage:(UIImage *)image action:(SEL)action
{
    return [self.navigatonBar setRightItemWithImage:image target:self action:action];
}

- (UIButton *)setRightItemWithTitle:(NSString *)title action:(SEL)action
{
    return [self.navigatonBar setRightItemWithTitle:title target:self action:action];
}

@end
