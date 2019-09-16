//
//  GKDChildPageViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/9.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDChildPageViewController.h"
#import <UIScrollView+GKNestedScroll.h>

@interface GKDChildPageViewController ()

@property(nonatomic, assign) NSTimeInterval time;
@property(nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic, assign) CGFloat lastY;
@property(nonatomic, assign) CGFloat speed;
@property(nonatomic, strong) CADisplayLink *link;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) CGFloat ac;


@end

@implementation GKDChildPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews
{
    [self registerClass:[UITableViewCell class]];
    self.tableView.gkNestedScrollEnable = YES;
    [super initViews];
  //  self.refreshEnable = YES;
    self.loadMoreEnable = YES;
    [self stopLoadMoreWithMore:YES];
}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self.link invalidate];
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    if(velocity.y < 0){
//        self.speed = 0;
//        return;
//    }
//
//    NSLog(@"velocity = %@, offset = %f", NSStringFromCGPoint(velocity), scrollView.contentOffset.y);
//    self.time = [NSDate date].timeIntervalSince1970;
//    self.speed = velocity.y;
////    *targetContentOffset = CGPointMake(0, scrollView.contentOffset.y + 200);
//    self.timeInterval = NSDate.date.timeIntervalSince1970 * 1000;
//    self.lastY = scrollView.contentOffset.y;
//    NSInteger i = 0;
//    CGFloat speed = self.speed;
//    while (speed > 0.01) {
//
//        speed *= 0.81;
//        i ++;
//    }
//    self.ac = 0.81;
//    //i * 100.0f / 1000.0f
//    *targetContentOffset = scrollView.contentOffset;
//
//    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleLink)];
//    [self.link addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
//}
//
//- (void)handleLink
//{
//    self.count ++;
//    if(self.count > 6){
//        self.count = 0;
//        if(self.tableView.contentOffset.y + self.tableView.gkHeight > self.tableView.contentSize.height){
//            self.ac *= 0.5;
//        }
//        self.speed *= self.ac;
//    }
//
//    if(self.speed <= 0.01){
//
//        if(self.tableView.contentOffset.y + self.tableView.gkHeight > self.tableView.contentSize.height){
//            self.speed = -0.65;
//            self.ac = 0.81;
//        }else{
//            [self.link invalidate];
//            return;
//        }
//
//    }
//
//    CGFloat y = self.tableView.contentOffset.y + self.speed * 17;
//
//    self.tableView.contentOffset = CGPointMake(0, y);
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"time = %f, offset = %f", NSDate.date.timeIntervalSince1970 - self.time, scrollView.contentOffset.y);
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.speed == 0)
        return;
//    NSTimeInterval time = NSDate.date.timeIntervalSince1970 * 1000;
//    if(time - self.timeInterval >= 17){
//        self.timeInterval = time;
//
//        CGFloat speed = (scrollView.contentOffset.y - self.lastY) / 17;
//        NSLog(@"scroll %f", speed);
//        self.speed = speed;
//        self.lastY = scrollView.contentOffset.y;
//    }
}

- (void)onRefesh
{
    [super onRefesh];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
}

- (void)onLoadMore
{
    [super onLoadMore];
    [self performSelector:@selector(stopLoadMoreWithMore:) withObject:@(NO) afterDelay:2.0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 130;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell gkNameOfClass] forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld个", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"click child");
}

@end
