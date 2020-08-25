//
//  GKDBannerViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/8/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDBannerViewController.h"
#import <GKPageView.h>

@interface GKDBannerViewController ()<GKPageViewDelegate>

///
@property(nonatomic, strong) NSArray<UIColor*> *colors;

///
@property(nonatomic, strong) GKPageView *horizontalPageView;

///
@property(nonatomic, strong) GKPageView *verticalPageView;

@end

@implementation GKDBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Banner";
    
    self.colors = @[UIColor.redColor, UIColor.orangeColor, UIColor.yellowColor, UIColor.greenColor, UIColor.cyanColor, UIColor.blueColor, UIColor.purpleColor];
    
    GKPageView *view = [GKPageView new];
//    view.spacing = 20;
    view.ratio = 0.8;
    view.scale = 0.9;
    view.delegate = self;
    view.autoPlay = NO;
    [view registerClass:UIView.class];
    [self.view addSubview:view];
    self.horizontalPageView = view;
    
    [self setTopView:view height:200];
    
    view = [[GKPageView alloc] initWithScrollDirection:GKPageViewScrollDirectionVertical];
    view.ratio = 0.8;
    view.scale = 0.9;
    view.delegate = self;
    view.autoPlay = NO;
    [view registerClass:UIView.class];
    [self.view addSubview:view];
    self.verticalPageView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(0);
        make.top.equalTo(self.topView.mas_bottom).offset(30);
        make.height.equalTo(200);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Scroll To Random" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(handleScroll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(0);
        make.top.equalTo(view.mas_bottom).offset(30);
    }];
}

// MARK: - GKPageViewDelegate

- (NSInteger)numberOfItemsInPageView:(GKPageView *)pageView
{
    return 3;
}

- (UIView*)pageView:(GKPageView *)pageView cellForItemAtIndex:(NSInteger)index
{
    UIView *cell = [pageView dequeueCellForClass:UIView.class forIndex:index];
    cell.backgroundColor = self.colors[index];
    
    return cell;
}

- (void)pageView:(GKPageView *)pageView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"didSelectItemAtIndex %ld", index);
}

- (void)pageView:(GKPageView *)pageView didMiddleItemAtIndex:(NSInteger)index
{
    NSLog(@"didMiddleItemAtIndex %ld", index);
}

// MARK: - Action

- (void)handleScroll
{
    NSInteger index = arc4random() % self.colors.count;
    NSLog(@"scroll to %ld", index);
    [self.horizontalPageView scrollToIndex:index animated:YES];
    [self.verticalPageView scrollToIndex:index animated:YES];
}

@end
