//
//  GKBaseViewModel.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/20.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKBaseViewModel.h"
#import "GKHttpTask.h"
#import "GKHttpMultiTasks.h"
#import "UIViewController+GKLoading.h"

@interface GKBaseViewModel()

@end

@implementation GKBaseViewModel

- (instancetype)initWithController:(GKBaseViewController*) viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
        self.shouldShowPageLoading = YES;
    }
    
    return self;
}

+ (instancetype)viewModelWithController:(GKBaseViewController*) viewController
{
    return [[[self class] alloc] initWithController:viewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)addCanceledTask:(GKHttpTask*) task
{
    [self.viewController addCanceledTask:task];
}

- (void)addCanceledTask:(GKHttpTask*) task cancelTheSame:(BOOL) cancel
{
    [self.viewController addCanceledTask:task cancelTheSame:cancel];
}

- (void)addCanceledTasks:(GKHttpMultiTasks*) tasks
{
    [self.viewController addCanceledTasks:tasks];
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
