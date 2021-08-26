//
//  GKDBannerViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/8/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDBannerViewController.h"
#import <GKPageView.h>

@interface GKDBannerViewController ()<GKPageViewDelegate, UIScrollViewDelegate>

///
@property(nonatomic, strong) NSArray<UIColor*> *colors;

///
@property(nonatomic, strong) GKPageView *horizontalPageView;

///
@property(nonatomic, strong) GKPageView *verticalPageView;

///
@property(nonatomic, strong) UIScrollView *scrollView;

@end

@implementation GKDBannerViewController
{
    CGFloat _last;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Banner";
    
    self.colors = @[UIColor.redColor, UIColor.orangeColor, UIColor.yellowColor, UIColor.greenColor, UIColor.cyanColor, UIColor.blueColor, UIColor.purpleColor];
    
    GKPageView *view = [GKPageView new];
    view.scrollInfinitely = NO;
//    view.spacing = 20;
//    view.ratio = 0.8;
//    view.scale = 0.9;
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

    NSArray *colors = @[UIColor.redColor, UIColor.orangeColor, UIColor.yellowColor, UIColor.greenColor, UIColor.cyanColor, UIColor.blueColor, UIColor.purpleColor];
    NSArray *widths = @[@100, @130, @200, @250, @180, @320, @150];
    CGFloat margin = 0;
    CGFloat totalWith = margin;
    CGFloat height = 200;
    
    UIScrollView *scrollView = [UIScrollView new];
    for (NSInteger i = 0; i < colors.count; i ++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(totalWith, 0, UIScreen.gkWidth - margin * 2, height)];
        view.backgroundColor = colors[i];
        [scrollView addSubview:view];
        
        totalWith += margin + UIScreen.gkWidth - margin * 2;
    }
    scrollView.contentSize = CGSizeMake(totalWith, height);
    scrollView.delegate = self;
    scrollView.scrollEnabled = NO;
    [scrollView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
//    [scrollView.panGestureRecognizer addTarget:self action:@selector(handlePan:)];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(0);
        make.height.equalTo(height);
        make.top.equalTo(btn.mas_bottom).offset(20);
    }];
    self.scrollView = scrollView;
}



- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan : {
            [pan setTranslation:CGPointMake(-self.scrollView.contentOffset.x, 0) inView:self.scrollView];
            _last = [pan translationInView:self.scrollView].x;
        }
            break;
        case UIGestureRecognizerStateChanged : {
            CGPoint point = [pan translationInView:self.scrollView];
            self.scrollView.contentOffset = CGPointMake(-point.x, 0);
            _last = [pan translationInView:self.scrollView].x;
//            NSLog(@"changed velocity %f", [pan velocityInView:self.view].x);
        }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateCancelled : {
            CGPoint point = [pan translationInView:self.scrollView];
            
//            NSLog(@"velocity %f", [pan velocityInView:self.scrollView.subviews.firstObject].x);
            CGFloat x = fabs(point.x + [pan velocityInView:self.scrollView].x * 0.490750);
            NSInteger page = floor(self.scrollView.contentOffset.x / UIScreen.gkWidth);
            
            CGFloat value = x - UIScreen.gkWidth * page;
            NSLog(@"%f, %f", value, x);
            if (value >= UIScreen.gkWidth / 2) {
                page ++;
            }
            if (page >= 7) {
                return;
            }
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                            [self.scrollView setContentOffset:CGPointMake(page * UIScreen.gkWidth, 0)];
            } completion:nil];
        }
            break;
        default:
            break;
    }
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    scrollView.contentOffset = CGPointZero;
//    NSLog(@"cx %f", scrollView.contentOffset.x);
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    NSLog(@"velocity %f, %f", velocity.x, [scrollView.panGestureRecognizer velocityInView:scrollView].x);
//    NSLog(@"%f, %f", scrollView.contentOffset.x, targetContentOffset->x);
//    NSLog(@"%f", (targetContentOffset->x - scrollView.contentOffset.x) / velocity.x / 1000);
//}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    CGFloat x = scrollView.contentOffset.x;
//    CGFloat width = UIScreen.gkWidth - 0;
//    if (x <= 0 || x >= scrollView.contentSize.width - width) {
//        return;
//    }
//    NSLog(@"%f,target %f", x, targetContentOffset->x);
//
//
//
//    NSInteger page = floor(scrollView.contentOffset.x / width);
//    if (targetContentOffset->x < x) {
//
//    } else {
//        page ++;
//    }
//
//    if (page >= 0 && page < 7) {
//        *targetContentOffset = CGPointMake(page * width, 0);
//    }
//}

// MARK: - GKPageViewDelegate

- (NSInteger)numberOfItemsInPageView:(GKPageView *)pageView
{
    return self.colors.count;
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
