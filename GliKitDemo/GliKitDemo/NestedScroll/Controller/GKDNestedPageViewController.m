//
//  GKDNestedPageViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNestedPageViewController.h"
#import "GKDChildPageViewController.h"
#import <GKMenuBar.h>
#import <UIScrollView+GKNestedScroll.h>

@interface GKDNestedPageViewController ()

@property(nonatomic, strong) NSMutableArray<GKDChildPageViewController*> *subPages;

@property(nonatomic, weak) GKDChildPageViewController *subPage;

@end

@implementation GKDNestedPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *titles = @[@"平板电视", @"冰箱", @"家庭影院", @"洗衣机", @"空调", @"热水器", @"电风扇", @"微波炉"];
    self.subPages = [NSMutableArray arrayWithCapacity:titles.count];
    for(NSInteger i = 0;i < titles.count;i ++){
        GKDChildPageViewController *page = [GKDChildPageViewController new];
        page.index = i;
        [self.subPages addObject:page];
    }
    self.menuBar.titles = titles;
    self.menuBar.props.selectedTextColor = [UIColor colorWithRed:0 green:0.4784314 blue:1.0 alpha:1.0];
    self.menuBar.props.indicatorColor = [UIColor colorWithRed:0 green:0.4784314 blue:1.0 alpha:1.0];
    self.menuBar.props.displayBottomDivider = YES;
    self.menuBar.props.displayTopDivider = YES;
    
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //设置parent
    UIScrollView *child = self.subPages[self.currentPage].scrollView;
    UIScrollView *parent = child.gkNestedParentScrollView;
    parent.gkNestedChildScrollView = child;
    if(!parent.gkChildDidScrollToParent){
        WeakObj(self)
        parent.gkChildDidScrollToParent = ^{
            for(GKDChildPageViewController *page in selfWeak.pageViewControllers){
                if(page.isInit){
                    page.scrollView.contentOffset = CGPointZero;
                }
            }
        };
    }
}

- (UIViewController*)viewControllerForIndex:(NSUInteger)index
{
    return self.subPages[index];
}

- (void)onScrollTopPage:(NSInteger)page
{
    self.subPage = self.subPages[page];
    self.subPage.scrollView.gkNestedParentScrollView.gkNestedChildScrollView = self.subPage.scrollView;
}

@end
