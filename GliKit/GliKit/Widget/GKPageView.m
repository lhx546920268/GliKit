//
//  GKPageView.m
//  GliKit
//
//  Created by 罗海雄 on 2020/8/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKPageView.h"
#import "UIView+GKUtils.h"
#import <objc/runtime.h>
#import "GKCountDownTimer.h"
#import "GKBaseDefines.h"

static char GKReusableIdentifierKey;
static char GKPageIndexKey;

@interface UIView (GKPageViewIdentifier)

///复用标识
@property(nonatomic, copy) NSString *gkReusableIdentifier;

///下标
@property(nonatomic, assign) NSInteger gkPageIndex;

@end

@implementation UIView (GKPageViewIdentifier)

- (void)setGkReusableIdentifier:(NSString *)gkReusableIdentifier
{
    objc_setAssociatedObject(self, &GKReusableIdentifierKey, gkReusableIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)gkReusableIdentifier
{
    return objc_getAssociatedObject(self, &GKReusableIdentifierKey);
}

- (void)setGkPageIndex:(NSInteger)gkPageIndex
{
    objc_setAssociatedObject(self, &GKPageIndexKey, @(gkPageIndex), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)gkPageIndex
{
    return [objc_getAssociatedObject(self, &GKPageIndexKey) integerValue];
}

@end

///主要是为了重写hitTest
@interface GKPageScrollView : UIScrollView

@end

@implementation GKPageScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //让超出UIScrollView范围的 响应点击事件
    UIView *view = [super hitTest:point withEvent:event];
    
    if(!view){
        NSArray *subviews = self.subviews;
        for(NSInteger i = subviews.count - 1;i >= 0;i --){
            UIView *subview = subviews[i];
            if(!subview.hidden && subview.alpha > 0.01
               && subview.userInteractionEnabled
               && CGRectContainsPoint(subview.frame, point)){
                return subview;
            }
        }
    }
    
    return view;
}

@end

@interface GKPageView ()<UIScrollViewDelegate>

///item总数
@property(nonatomic, assign) NSInteger numberOfItems;

///当前可见的cell
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, UIView*> *visibleCells;
@property(nonatomic, strong) NSMutableSet<UIView*> *visibleSet;

///可重用的cell
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSMutableSet<UIView*>*> *reusableCells;

///注册的cell
@property(nonatomic, strong) NSMutableDictionary<NSString*, id> *registerCells;

///旧的大小
@property(nonatomic, assign) CGSize oldSize;

///滑动方向
@property(nonatomic, assign) GKPageViewScrollDirection scrollDirection;

///是否需要循环滚动
@property(nonatomic,assign) BOOL shouldScrollInfinitely;

///起始位置
@property(nonatomic,assign) CGPoint contentOffset;

///获取页面大小
@property(nonatomic, readonly) CGFloat pageSize;

///当前要显示的item数量
@property(nonatomic, readonly) NSInteger numberOfNeededItems;

///计时器
@property(nonatomic,strong) GKCountDownTimer *timer;

@end

@implementation GKPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _scrollDirection = GKPageViewScrollDirectionHorizontal;
        [self initProps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        _scrollDirection = GKPageViewScrollDirectionHorizontal;
        [self initProps];
    }
    return self;
}

- (instancetype)initWithScrollDirection:(GKPageViewScrollDirection)scrollDirection
{
    self = [super initWithFrame:CGRectZero];
    if(self){
        _scrollDirection = scrollDirection;
        [self initProps];
    }
    
    return self;
}

- (void)initProps
{
    _ratio = 1.0;
    _spacing = 0;
    _scale = 1.0;
    _scrollInfinitely = YES;
    _autoPlay = YES;
    _playTimeInterval = 5.0;
    _shouldMiddleItem = YES;
    
    self.clipsToBounds = YES;
    
    _scrollView = [[GKPageScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.pagingEnabled = YES;
    
    if(@available(iOS 11.0, *)){
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:_scrollView];
}

- (NSMutableDictionary<NSNumber *,UIView *> *)visibleCells
{
    if(!_visibleCells){
        _visibleCells = [NSMutableDictionary new];
    }
    return _visibleCells;
}

- (NSMutableSet<UIView *> *)visibleSet
{
    if(!_visibleSet){
        _visibleSet = [NSMutableSet set];
    }
    return _visibleSet;
}

- (NSMutableDictionary<NSString *,NSMutableSet<UIView *> *> *)reusableCells
{
    if(!_reusableCells){
        _reusableCells = [NSMutableDictionary new];
    }
    
    return _reusableCells;
}

- (NSMutableDictionary<NSString *,id> *)registerCells
{
    if(!_registerCells){
        _registerCells = [NSMutableDictionary new];
    }

    return _registerCells;
}

// MARK: - public method

- (void)registerClass:(Class)cls
{
    NSParameterAssert(cls != nil);
    self.registerCells[NSStringFromClass(cls)] = cls;
}

- (void)registerNib:(Class)cls
{
    NSParameterAssert(cls != nil);
    NSString *name = NSStringFromClass(cls);
    self.registerCells[name] = [UINib nibWithNibName:name bundle:nil];
}

- (UIView *)dequeueCellForClass:(Class)cls forIndex:(NSInteger)index
{
    NSParameterAssert(cls != nil);
    return [self dequeueCellForIdentifier:NSStringFromClass(cls) forIndex:index];
}

- (void)reloadData
{
    [self.visibleSet removeAllObjects];
    [self.visibleCells removeAllObjects];
    [self.reusableCells removeAllObjects];
    [self gkRemoveAllSubviews];
    
    [self layoutIfEnabled];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)flag
{
    NSInteger count = self.numberOfItems;
    NSInteger originIndex = index;
    if(self.shouldScrollInfinitely){
        index += 2;
        count += 4;
    }
    
    if(index >= 0 && index < count){
        self.contentOffset = self.scrollView.contentOffset;
        //如果当前是第一个或者最后一个item，反向滑动
        if(self.currentPage == 0 && originIndex == self.numberOfItems - 1){
            index = 1;
        }else if(self.currentPage == self.numberOfItems - 1 && originIndex == self.numberOfItems - 2){
            index = 0;
        }
        
        CGFloat offset = [self offsetForIndex:index];
   
        switch (self.scrollDirection) {
            case GKPageViewScrollDirectionHorizontal : {
                [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:flag];
            }
                break;
            case GKPageViewScrollDirectionVertical : {
                [self.scrollView setContentOffset:CGPointMake(0, offset) animated:flag];
            }
                break;
        }
    }
}

- (UIView *)cellForIndex:(NSInteger)index
{
    if(self.shouldScrollInfinitely){
        index += 2;
    }
    return [self cellForIndex:index shouldInit:NO];
}

- (void)setPlayTimeInterval:(NSTimeInterval)playTimeInterval
{
    if(_playTimeInterval != playTimeInterval){
        _playTimeInterval = playTimeInterval;
        BOOL excuting = self.timer.isExcuting;
        self.timer.timeInterval = _playTimeInterval;
        if(excuting){
            [self.timer start];
        }
    }
}

- (void)setAutoPlay:(BOOL)autoPlay
{
    if(_autoPlay != autoPlay){
        _autoPlay = autoPlay;
        if(_autoPlay && !self.scrollView.decelerating && !self.scrollView.dragging){
            [self startAnimating];
        }else{
            [self stopAnimating];
        }
    }
}

// MARK: - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(!CGSizeEqualToSize(self.bounds.size, self.oldSize)){
        self.oldSize = self.bounds.size;
        [self layoutIfEnabled];
    }
}

///准备布局
- (void)prelayout
{
    self.numberOfItems = [self.delegate numberOfItemsInPageView:self];
    self.shouldScrollInfinitely = self.scrollInfinitely && self.numberOfItems > 1;
    _currentPage = 0;
    
    NSInteger count = self.numberOfNeededItems;

    switch (self.scrollDirection) {
        case GKPageViewScrollDirectionHorizontal : {
            CGFloat pageWidth = self.pageSize + self.spacing;
            CGFloat margin = (self.gkWidth - pageWidth) / 2;
            self.scrollView.frame = CGRectMake(margin, 0, pageWidth, self.gkHeight);
            self.scrollView.contentSize = CGSizeMake(count * self.scrollView.gkWidth, self.scrollView.gkHeight);
        }
            break;
        case GKPageViewScrollDirectionVertical : {
            CGFloat pageHeight = self.pageSize + self.spacing;
            CGFloat margin = (self.gkHeight - pageHeight) / 2;
            self.scrollView.frame = CGRectMake(0, margin, self.gkWidth, pageHeight);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.gkWidth, count * self.scrollView.gkHeight);
        }
            break;
    }
}

- (void)layoutIfEnabled
{
    if(!CGSizeEqualToSize(CGSizeZero, self.bounds.size)){
        [self prelayout];
        if(self.numberOfItems > 0){
            [self scrollToIndex:0 animated:NO];
        }
        [self layoutItems];
        [self startAnimating];
    }
}

///重新布局子视图
- (void)layoutItems
{
    if(self.numberOfItems <= 0)
        return;
    
    switch (self.scrollDirection) {
        case GKPageViewScrollDirectionHorizontal:
            [self layoutHorizontalItems];
            break;
        case GKPageViewScrollDirectionVertical :
            [self layoutVerticalItems];
            break;
    }
}

- (void)layoutHorizontalItems
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGFloat pageWidth = self.pageSize;
    CGFloat left = self.spacing / 2;
    NSInteger count = self.numberOfNeededItems;
    
    NSInteger pageIndex = MAX(floor(offsetX / (pageWidth + self.spacing)), 0);
    
    //显示当前item
    [self configureCellforIndex:pageIndex];
    
    //显示后面的 并且在可见范围内的
    NSInteger nextPageIndex = pageIndex + 1;
    CGFloat x = left + nextPageIndex * (pageWidth + self.spacing);
    while (nextPageIndex < count && x < offsetX + self.scrollView.gkRight) {
        [self configureCellforIndex:nextPageIndex];
        x += pageWidth + self.spacing;
        nextPageIndex ++;
    }

    //显示前面的
    NSInteger previousPageIndex = pageIndex - 1;
    x = left + previousPageIndex * (pageWidth + self.spacing);
    while (previousPageIndex >= 0 && x + pageWidth > offsetX - self.scrollView.gkLeft) {
        [self configureCellforIndex:previousPageIndex];
        x -= pageWidth + self.spacing;
        previousPageIndex --;
    }
    
    [self recycleInvisibleCells];
}

- (void)layoutVerticalItems
{
    CGFloat offsetY = self.scrollView.contentOffset.y;
    CGFloat pageHeight = self.pageSize;
    CGFloat top = self.spacing / 2;
    NSInteger count = self.numberOfNeededItems;
    
    NSInteger pageIndex = MAX(floor(offsetY / (pageHeight + self.spacing)), 0);
    
    //显示当前item
    [self configureCellforIndex:pageIndex];
    
    //显示后面的 并且在可见范围内的
    NSInteger nextPageIndex = pageIndex + 1;
    CGFloat y = top + nextPageIndex * (pageHeight + self.spacing);
    while (nextPageIndex < count && y < offsetY + self.scrollView.gkBottom) {
        [self configureCellforIndex:nextPageIndex];
        y += pageHeight + self.spacing;
        nextPageIndex ++;
    }

    //显示前面的
    NSInteger previousPageIndex = pageIndex - 1;
    y = top + previousPageIndex * (pageHeight + self.spacing);
    while (previousPageIndex >= 0 && y + pageHeight > offsetY - self.scrollView.gkTop) {
        [self configureCellforIndex:previousPageIndex];
        y -= pageHeight + self.spacing;
        previousPageIndex --;
    }

    [self recycleInvisibleCells];
}

//配置cell
- (void)configureCellforIndex:(NSInteger) index
{
    UIView *cell = [self cellForIndex:index shouldInit:YES];
    cell.transform = CGAffineTransformIdentity;
    CGFloat pageSize = self.pageSize;
    
    switch (self.scrollDirection) {
        case GKPageViewScrollDirectionHorizontal : {
            
            cell.frame = CGRectMake([self offsetForIndex:index] + self.spacing / 2, 0, pageSize, self.gkHeight);
            
            if(self.scale < 1.0){
                CGPoint center = [self.scrollView convertPoint:cell.center toView:self];
                CGFloat scale = 1.0 - (1.0 - self.scale) * fabs(center.x - self.scrollView.center.x) / (pageSize + self.spacing);
                cell.transform = CGAffineTransformMakeScale(scale, scale);
            }
        }
            break;
        case GKPageViewScrollDirectionVertical : {
            cell.frame = CGRectMake(0, [self offsetForIndex:index] + self.spacing / 2, self.gkWidth, pageSize);
            
            if(self.scale < 1.0){
                CGPoint center = [self.scrollView convertPoint:cell.center toView:self];
                CGFloat scale = 1.0 - (1.0 - self.scale) * fabs(center.y - self.scrollView.center.y) / (pageSize + self.spacing);
                cell.transform = CGAffineTransformMakeScale(scale, scale);
            }
        }
            break;
    }
    self.visibleCells[@(index)] = cell;
    [self.visibleSet addObject:cell];
}

///获取对应下标的偏移量
- (CGFloat)offsetForIndex:(NSInteger) index
{
    return index * (self.pageSize + self.spacing);
}

///获取某个cell，如果shouldInit，可见的cell不存在时会创建一个
- (UIView*)cellForIndex:(NSInteger) index shouldInit:(BOOL) shouldInit
{
    UIView *cell = self.visibleCells[@(index)];
    if(!cell && shouldInit){
        cell = [self.delegate pageView:self cellForItemAtIndex:[self getActualIndexFromIndex:index]];
    }
    
    return cell;
}

- (CGFloat)pageSize
{
    switch (self.scrollDirection) {
        case GKPageViewScrollDirectionHorizontal :
            return floor(self.ratio * self.gkWidth);
        case GKPageViewScrollDirectionVertical :
            return floor(self.ratio * self.gkHeight);
    }
}

- (NSInteger)numberOfNeededItems
{
    NSInteger count = self.numberOfItems;
    if(self.shouldScrollInfinitely){
        count += 4;
    }
    return count;
}

// MARK: - instantitate cell

///从队列里面获取可重用的cell，如果没有会实例化一个新的
- (UIView*)dequeueCellForIdentifier:(NSString*) identifier forIndex:(NSInteger) index
{
    NSMutableSet *set = self.reusableCells[identifier];
    UIView *cell = set.anyObject;
    if(!cell){
        cell = [self instantitateViewForIdentifier:identifier];
    }else{
        [set removeObject:cell];
    }
    
    cell.gkPageIndex = index;
    [self.scrollView addSubview:cell];
    
    return cell;
}

///实例化一个新的cell
- (UIView*)instantitateViewForIdentifier:(NSString*) identifier
{
    UIView *cell = nil;
    Class cls = self.registerCells[identifier];
    NSAssert(cls != nil, @"%@ cell for %@ does not register", NSStringFromClass(self.class), identifier);
    
    if([cls isKindOfClass:UINib.class]){
        UINib *nib = (UINib*)cls;
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
    }else{
        cell = [[cls alloc] init];
    }
    cell.gkReusableIdentifier = identifier;
    [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
    cell.userInteractionEnabled = YES;
 
    return cell;
}

///点击某个item了
- (void)handleTap:(UITapGestureRecognizer*) tap
{
    NSInteger index = tap.view.gkPageIndex;
    if(self.shouldMiddleItem && index != self.currentPage){
        [self scrollToIndex:index animated:YES];
        if([self.delegate respondsToSelector:@selector(pageView:didMiddleItemAtIndex:)]){
            [self.delegate pageView:self didMiddleItemAtIndex:index];
        }
    }else{
        if([self.delegate respondsToSelector:@selector(pageView:didSelectItemAtIndex:)]){
            [self.delegate pageView:self didSelectItemAtIndex:index];
        }
    }
}

// MARK: - Recycle

/////回收不可见的
- (void)recycleInvisibleCells
{
    NSArray *subviews = self.scrollView.subviews;
    for(UIView *view in subviews){
        if(![self.visibleSet containsObject:view]){
            [self recycleCell:view];
        }
    }
}

///回收
- (void)recycleCell:(UIView*) cell
{
    NSMutableSet *set = self.reusableCells[cell.gkReusableIdentifier];
    if(!set){
        set = [NSMutableSet set];
        self.reusableCells[cell.gkReusableIdentifier] = set;
    }
    [set addObject:cell];
    [self.visibleCells removeObjectForKey:@(cell.gkPageIndex)];
    [self.visibleSet removeObject:cell];
    [cell removeFromSuperview];
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    switch (self.scrollDirection) {
        case GKPageViewScrollDirectionHorizontal : {
            
            NSInteger page = MAX(0, floor(scrollView.contentOffset.x / (self.pageSize + self.spacing)));
      
            if(self.shouldScrollInfinitely){
                if(page == 0){
                    if(self.contentOffset.x > scrollView.contentOffset.x){
                        self.contentOffset = CGPointMake([self offsetForIndex:self.numberOfItems + 1], 0);
                        [self.scrollView setContentOffset:self.contentOffset]; // 最后+1,循环到第1页
                        _currentPage = 0;
                    }
                }else if (page >= (self.numberOfItems + 1)){
                    
                    if(self.contentOffset.x < scrollView.contentOffset.x){
                        self.contentOffset = CGPointMake([self offsetForIndex:1], 0);
                        [self.scrollView setContentOffset:self.contentOffset];// 最后+1,循环第1页
                        _currentPage = self.numberOfItems - 1;
                    }
                }else{
                    _currentPage = [self getActualIndexFromIndex:page];
                }
            }else{
                _currentPage = page;
            }
        }
            break;
        case GKPageViewScrollDirectionVertical : {
            NSInteger page = floor(scrollView.contentOffset.y / (self.pageSize + self.spacing));
            
            if(self.shouldScrollInfinitely){
                if(page == 0){
                    if(self.contentOffset.y > scrollView.contentOffset.y){
                        self.contentOffset = CGPointMake(0, [self offsetForIndex:self.numberOfItems + 1]);
                        [self.scrollView setContentOffset:self.contentOffset]; // 最后+1,循环到第1页
                        _currentPage = 0;
                    }
                }else if (page >= (self.numberOfItems + 1)){
                    if(self.contentOffset.y < scrollView.contentOffset.y){
                        self.contentOffset = CGPointMake(0, [self offsetForIndex:1]);
                        [self.scrollView setContentOffset:self.contentOffset]; // 最后+1,循环第1页
                        _currentPage = self.numberOfItems - 1;
                    }
                }else{
                    _currentPage = [self getActualIndexFromIndex:page];
                }
            }else{
                _currentPage = page;
            }
        }
            break;
    }
    
    [self layoutItems];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopAnimating];
    self.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        self.contentOffset = CGPointZero;
        [self startAnimating];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(!scrollView.dragging){
        self.contentOffset = CGPointZero;
        [self startAnimating];
    }
}

// MARK: -  private method

///获取实际的内容下标
- (NSInteger)getActualIndexFromIndex:(NSInteger) index
{
    NSInteger pageIndex = index;
    
    if(self.scrollInfinitely){
        pageIndex = index - 2;
        if(pageIndex < 0){
            pageIndex += self.numberOfItems;
        }
        
        if(pageIndex >= self.numberOfItems){
            pageIndex -= self.numberOfItems;
        }
    }
    return pageIndex;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //让超出UIScrollView范围的 响应点击事件
    UIView *view = [super hitTest:point withEvent:event];
    if(view == self){
        view = self.scrollView;
    }
    
    return view;
}

// MARK: -  timer

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(!CGSizeEqualToSize(self.bounds.size, CGSizeZero)){
        if(newWindow){
            [self startAnimating];
        }else{
            [self stopAnimating];
        }
    }
}

///开始动画
- (void)startAnimating
{
    if(!self.shouldScrollInfinitely || !self.autoPlay){
        [self stopAnimating];
        return;
    }
    
    if(!self.timer){
        WeakObj(self);
        self.timer = [GKCountDownTimer timerWithTime:GKCountDownInfinite interval:self.playTimeInterval];
        self.timer.shouldStartImmediately = NO;
        self.timer.tickHandler = ^(NSTimeInterval timeLeft){
            [selfWeak scrollAnimated];
        };
    }
    if(!self.timer.isExcuting){
        [self.timer start];
    }
}

///结束动画
- (void)stopAnimating
{
    if(self.timer && self.timer.isExcuting){
        [self.timer stop];
    }
}

//.计时器滚动
- (void)scrollAnimated
{
    if(self.numberOfItems == 0)
        return;
    [self pageChangedAnimated:YES];
}

///滚动动画
- (void)pageChangedAnimated:(BOOL) flag
{
    NSInteger page = self.currentPage; // 获取当前的page
    if(page < self.numberOfItems){
        [self scrollToIndex:page + 1 animated:flag];
    }
}

@end
