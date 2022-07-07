//
//  GKScrollViewConfig.m
//  GliKit
//
//  Created by 罗海雄 on 2021/2/23.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKScrollViewConfig.h"
#import "GKBaseDefines.h"

@implementation GKScrollViewConfig

@synthesize viewController = _viewController;

- (instancetype)initWithController:(GKScrollViewController*) viewController
{
    self = [super init];
    if(self){
        _viewController = viewController;
    }
    
    return self;
}

- (__kindof GKScrollViewController *)viewController
{
    return _viewController;
}

- (__kindof GKScrollViewModel *)viewModel
{
    return (GKScrollViewModel*)self.viewController.viewModel;
}

- (UINavigationController *)navigationController
{
    return _viewController.navigationController;
}

+ (instancetype)configWithController:(GKScrollViewController*) viewController
{
    return [[[self class] alloc] initWithController:viewController];
}

- (void)config
{
    GKThrowNotImplException
}

@end
