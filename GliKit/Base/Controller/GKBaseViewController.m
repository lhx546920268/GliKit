//
//  GKBaseViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/14.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewController.h"
#import "GKWeakObjectContainer.h"
#import "NSObject+GKUtils.h"
#import "GKContainer.h"
#import "GKHttpTask.h"
#import "GKHttpMultiTasks.h"
#import "UIViewController+GKKeyboard.h"
#import "GKBaseViewModel.h"
#import "GKNavigationBar.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "GKSystemNavigationBar.h"
#import "GKNavigationItemHelper.h"
#import "UIViewController+GKUtils.h"
#import "UIView+GKUtils.h"
#import "UIViewController+GKDialog.h"
#import "GKBaseDefines.h"
#import "UIApplication+GKTheme.h"

@interface GKBaseViewController ()<UIGestureRecognizerDelegate>

///用来在delloc之前 要取消的请求
@property(nonatomic, strong) NSMutableSet<GKWeakObjectContainer*> *currentTasks;

///点击回收键盘手势
@property(nonatomic, strong) UITapGestureRecognizer *dismissKeyboardGestureRecognizer;

@end

@implementation GKBaseViewController

@synthesize navigationItemHelper = _navigationItemHelper;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.hidesBottomBarWhenPushed = YES;
        self.shouldCreateNavigationBar = YES;
    }
    return self;
}

- (CGFloat)compatiableStatusHeight
{
    CGFloat statusHeight = self.gkStatusBarHeight;
    CGFloat safeAreaTop = 0;
    if(@available(iOS 11, *)){
        safeAreaTop = self.view.gkSafeAreaInsets.top;
    }else{
        safeAreaTop = self.topLayoutGuide.length;
    }
    if(!self.navigationController.navigationBarHidden && self.navigationController.navigationBar.translucent){
        if(safeAreaTop > self.gkNavigationBarHeight){
            safeAreaTop -= self.gkNavigationBarHeight;
        }
    }
    
    if(statusHeight != safeAreaTop){
        statusHeight = 0;
    }
    
    return statusHeight;
}

//MARK: 内容视图

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

//MARK: View Life Cycle


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
    self.systemNavigationBar.enable = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.viewModel){
        [self.viewModel viewDidAppear:animated];
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.hidesBackButton = YES;
    
    //显示自定义导航栏
    if(self.shouldCreateNavigationBar && [self.parentViewController isKindOfClass:[UINavigationController class]]){
        _navigatonBar = [self.navigationBarClass new];
        [self.view addSubview:_navigatonBar];
        
        [_navigatonBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.view);
            make.bottom.equalTo(self.gkSafeAreaLayoutGuideTop);
        }];
    }
    
    if(self.isShowAsDialog){
        if(self.container){
            self.container.safeLayoutGuide = GKSafeLayoutGuideNone;

            //当 self.view 不是 container时， container中的子视图布局完成不会调用 viewDidLayoutSubviews 要手动，否则在 viewDidLayoutSubviews中获取 self.contentView的大小时会失败
            WeakObj(self);
            self.container.layoutSubviewsHandler = ^(void){
                [selfWeak viewDidLayoutSubviews];
            };
            [self.view addSubview:self.container];
        }
    }else{
    
        self.view.backgroundColor = [UIColor whiteColor];
        if(self.navigationController.viewControllers.count > 1 && !self.gkShowBackItem){
            self.gkShowBackItem = YES;
        }
    }
}

//MARK: 导航栏

- (Class)navigationBarClass
{
    return [GKNavigationBar class];
}

- (void)setNavigatonBarHidden:(BOOL)hidden animate:(BOOL)animate
{
    self.navigatonBar.hidden = hidden;
    GKSystemNavigationBar *navigationBar = self.systemNavigationBar;
    if(navigationBar){
        navigationBar.enable = !hidden;
        self.navigationItemHelper.hiddenItem = hidden;
    }else{
        [self.navigationController setNavigationBarHidden:hidden animated:animate];
    }
}

- (GKSystemNavigationBar*)systemNavigationBar
{
    if([self.navigationController.navigationBar isKindOfClass:GKSystemNavigationBar.class]){
        return (GKSystemNavigationBar*)self.navigationController.navigationBar;
    }
    
    return nil;
}

- (GKNavigationItemHelper*)navigationItemHelper
{
    if(!_navigationItemHelper){
        _navigationItemHelper = [[GKNavigationItemHelper alloc] initWithViewController:self];
    }
    
    return _navigationItemHelper;
}

//MARK: GKEmptyViewDelegate

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    view.iconImageView.image = [UIImage imageNamed:@"empty"];
    view.textLabel.text = @"暂无数据";
}

//MARK: 加载数据

- (void)gkReloadData
{
    if(self.viewModel){
        [self.viewModel reloadData];
    }
}

- (void)onLoadData
{
    
}

//MARK: UIStatusBar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if(self.isShowAsDialog){
        return UIStatusBarStyleLightContent;
    }else{
        return UIApplication.gkStatusBarStyle;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _isViewDidLayoutSubviews = YES;
    if(self.navigatonBar){
        [self.view bringSubviewToFront:self.navigatonBar];
    }
}

//MARK: Task

- (void)addCanceledTask:(GKHttpTask*) task
{
    [self addCanceledTask:task cancelTheSame:NO];
}

- (void)addCanceledTask:(GKHttpTask *)task cancelTheSame:(BOOL)cancel
{
    [self removeInvalidTasksAndCancelTheSame:cancel forName:task.name];
    if(task){
        if(!self.currentTasks){
            self.currentTasks = [NSMutableSet set];
        }
        [self.currentTasks addObject:[GKWeakObjectContainer containerWithObject:task]];
    }
}

- (void)addCanceledTasks:(GKHttpMultiTasks*) tasks
{
    [self removeInvalidTasksAndCancelTheSame:NO forName:nil];
    if(tasks){
        if(!self.currentTasks){
            self.currentTasks = [NSMutableSet set];
        }
        [self.currentTasks addObject:[GKWeakObjectContainer containerWithObject:tasks]];
    }
}

///移除无效的请求
- (void)removeInvalidTasksAndCancelTheSame:(BOOL) cancel forName:(NSString*) name
{
    if(self.currentTasks.count > 0){
        NSMutableSet *toRemoveTasks = [NSMutableSet set];
        for(GKWeakObjectContainer *obj in self.currentTasks){
            if(obj.weakObject == nil){
                [toRemoveTasks addObject:obj];
            }if([obj.weakObject isKindOfClass:[GKHttpTask class]]){
                GKHttpTask *task = (GKHttpTask*)obj.weakObject;
                if([task.name isEqualToString:name]){
                    [task cancel];
                    [toRemoveTasks addObject:obj];
                }
            }
        }
        
        [self.currentTasks minusSet:toRemoveTasks];
    }
}

- (void)dealloc
{
    //取消正在执行的请求
    for(GKWeakObjectContainer *obj in self.currentTasks){
        if([obj.weakObject isKindOfClass:[GKHttpTask class]]){
            GKHttpTask *task = (GKHttpTask*)obj.weakObject;
            [task cancel];
        }else if ([obj.weakObject isKindOfClass:[GKHttpMultiTasks class]]){
            GKHttpMultiTasks *tasks = (GKHttpMultiTasks*)obj.weakObject;
            [tasks cancelAllTasks];
        }
    }
}

//MARK: 键盘

- (void)setShouldDismissKeyboardWhileTap:(BOOL)shouldDismissKeyboardWhileTap
{
    if(_shouldDismissKeyboardWhileTap != shouldDismissKeyboardWhileTap){
        _shouldDismissKeyboardWhileTap = shouldDismissKeyboardWhileTap;
        if(!self.tapDialogBackgroundGestureRecognizer){
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

//MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.view;
}


@end
