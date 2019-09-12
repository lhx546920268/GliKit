//
//  GKDNestedParentViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDNestedParentViewController.h"
#import "GKDNestedTableViewCell.h"
#import "GKDNestedPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKDNestedPageCell : UITableViewCell

///要显示的viewController
@property(nonatomic, strong) UIViewController *viewController;

///父
@property(nonatomic, weak) UIViewController *parentViewController;

@end

@interface GKDNestedParentViewController ()

@property(nonatomic, strong) GKDNestedPageViewController *page;

///父scrollView 是否可以滑动
@property(nonatomic,assign) BOOL parentScrollEnable;

///子scrollView 是否可以滑动
@property(nonatomic,assign) BOOL childScrollEnable;

@property(nonatomic, assign) NSTimeInterval time;

@property(nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic, assign) CGFloat lastY;
@property(nonatomic, assign) CGFloat speed;
@property(nonatomic, strong) CADisplayLink *link;
@property(nonatomic, assign) NSInteger count;

@end

@implementation GKDNestedParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = [GKDNestedPageViewController new];
    
    [self initViews];
}

- (void)initViews
{
    [self registerNib:[GKDNestedTableViewCell class]];
    [self registerClassForHeaderFooterView:[UITableViewHeaderFooterView class]];
    [self registerClass:[GKDNestedPageCell class]];
    
    self.tableView.gkNestedParent = YES;
    self.tableView.gkNestedScrollEnable = YES;
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(handlePan:)];
    [super initViews];
}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    NSLog(@"velocity = %@, offset = %f", NSStringFromCGPoint(velocity), scrollView.contentOffset.y);
//    self.time = [NSDate date].timeIntervalSince1970;
//    self.speed = velocity.y;
//    //    *targetContentOffset = CGPointMake(0, scrollView.contentOffset.y + 200);
//    self.timeInterval = NSDate.date.timeIntervalSince1970 * 1000;
//    self.lastY = scrollView.contentOffset.y;
//    NSInteger i = 0;
//    CGFloat speed = self.speed;
//    while (speed > 0.01) {
//        
//        speed *= 0.81;
//        i ++;
//    }
//    //i * 100.0f / 1000.0f
////    *targetContentOffset = scrollView.contentOffset;
////    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleLink)];
////    [self.link addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
//}

- (void)handleLink
{
    self.count ++;
    if(self.count > 6){
        self.count = 0;
        self.speed *= 0.81;
    }
    
    if(self.speed <= 0.01){
        [self.link invalidate];
        return;
    }
    
    CGFloat y = self.tableView.contentOffset.y + self.speed * 17;
    self.tableView.contentOffset = CGPointMake(0, y);
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"time = %f, offset = %f", NSDate.date.timeIntervalSince1970 - self.time, scrollView.contentOffset.y);
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//        NSTimeInterval time = NSDate.date.timeIntervalSince1970 * 1000;
//        if(time - self.timeInterval >= 17){
//            self.timeInterval = time;
//
//            CGFloat speed = (scrollView.contentOffset.y - self.lastY) / 17;
//            NSLog(@"scroll %f", speed);
//            self.speed = speed;
//            self.lastY = scrollView.contentOffset.y;
//        }
//}


- (void)handlePan:(UIPanGestureRecognizer*) pan
{
//    CGPoint point = [pan translationInView:self.tableView];
//    NSLog(@"%@", NSStringFromCGPoint(point));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 3 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 45 : tableView.gkHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 50 : CGFLOAT_MIN;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[UITableViewHeaderFooterView gkNameOfClass]];
        
        header.textLabel.text = @"悬浮";
        
        return header;
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        GKDNestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[GKDNestedTableViewCell gkNameOfClass] forIndexPath:indexPath];
        
        [cell.btn setTitle:[NSString stringWithFormat:@"第%ld个按钮", indexPath.row] forState:UIControlStateNormal];
        cell.contentView.tag = indexPath.row + 1;
        
        return cell;
    }else{
        GKDNestedPageCell *cell = [tableView dequeueReusableCellWithIdentifier:[GKDNestedPageCell gkNameOfClass] forIndexPath:indexPath];
        cell.parentViewController = self;
        cell.viewController = self.page;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"click parent");
}


@end

@implementation GKDNestedPageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setViewController:(UIViewController *)viewController
{
    if(_viewController != viewController){
        if(_viewController){
            [_viewController removeFromParentViewController];
            [_viewController.view removeFromSuperview];
        }
        
        _viewController = viewController;
        [self.contentView addSubview:_viewController.view];
        [self.parentViewController addChildViewController:_viewController];
        
        [_viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
    }
}

@end
