//
//  GKBaseViewModel.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewModel.h"
#import "UIViewController+GKLoading.h"

@interface GKBaseViewModel()

@end

@implementation GKBaseViewModel

@synthesize viewController = _viewController;

- (instancetype)initWithController:(GKBaseViewController*) viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
        self.shouldShowPageLoading = YES;
    }
    
    return self;
}

- (__kindof GKBaseViewController *)viewController
{
    return _viewController;
}

+ (instancetype)viewModelWithController:(GKBaseViewController*) viewController
{
    return [[[self class] alloc] initWithController:viewController];
}

- (void)viewWillAppear:(BOOL)animated{}

- (void)viewDidAppear:(BOOL)animated{}

- (void)viewWillDisappear:(BOOL)animated{}

- (void)viewDidDisappear:(BOOL)animated{}

- (void)addCancelableTask:(id<GKCancelableTask>)task
{
    [self.viewController addCancelableTask:task];
}

- (void)addCancelableTask:(id<GKCancelableTask>)task cancelTheSame:(BOOL)cancel
{
    [self.viewController addCancelableTask:task cancelTheSame:cancel];
}

- (void)reloadData
{
    if(self.shouldShowPageLoading){
        self.viewController.gkShowPageLoading = YES;
    }
}

- (void)onLoadData
{
    if(self.shouldShowPageLoading){
        self.viewController.gkShowPageLoading = NO;
    }
    [self.viewController onLoadData];
}

@end
