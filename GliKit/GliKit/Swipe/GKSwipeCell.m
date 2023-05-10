//
//  GKSwipeCell.m
//  GliKit
//
//  Created by 罗海雄 on 2020/12/10.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKSwipeCell.h"
#import "UIImage+GKUtils.h"
#import "UIView+GKUtils.h"

///滑动显示的item
@interface GKSwipeItem : NSObject

///按钮
@property(nonatomic, strong) UIView *view;

///初始位置
@property(nonatomic, assign) CGRect startFrame;

///终点位置
@property(nonatomic, assign) CGRect endFrame;

+ (instancetype)itemWithView:(UIView*) view;

@end

@interface GKSwipeOverlay : UIView

///关联的cell
@property(nonatomic, weak, nullable) UIView<GKSwipeCell> *cell;

@end

@implementation GKSwipeItem

+ (instancetype)itemWithView:(UIView *)view
{
    GKSwipeItem *item = [GKSwipeItem new];
    item.view = view;
    
    return item;
}

@end

@implementation GKSwipeOverlay

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self.cell.superview convertRect:self.cell.frame toView:self];
    if(CGRectContainsPoint(rect, point)){
        return nil;
    }
    
    [self.cell setSwipeShow:NO direction:self.cell.currentDirection animated:YES];
    
    //不阻塞cell的事件
    if([self.superview isKindOfClass:UITableView.class]){
        UITableView *tableView = (UITableView*)self.superview;
        NSArray *cells = [tableView visibleCells];
        for(UITableViewCell *cell in cells){
            CGRect rect = [cell.superview convertRect:cell.frame toView:self];
            if(CGRectContainsPoint(rect, point)){
                return cell;
            }
        }
    }else if([self.superview isKindOfClass:UICollectionView.class]){
        UICollectionView *collectionView = (UICollectionView*)self.superview;
        NSArray *cells = [collectionView visibleCells];
        for(UICollectionViewCell *cell in cells){
            CGRect rect = [cell.superview convertRect:cell.frame toView:self];
            if(CGRectContainsPoint(rect, point)){
                return cell;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end

@interface GKSwipeCellHelper ()<UIGestureRecognizerDelegate>

///平移手势
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

///内容快照
@property(nonatomic, strong) UIImageView *snapshotView;

///当前按钮
@property(nonatomic, strong) NSArray<GKSwipeItem*> *currentSwipeItems;

///滑动的最大位置
@property(nonatomic, assign) CGFloat maxTranslationX;

///当前方向
@property(nonatomic, assign) GKSwipeDirection currentDirection;

///平移量
@property(nonatomic, assign) CGFloat translationX;

///覆盖物
@property(nonatomic, strong) GKSwipeOverlay *overlay;

///是否正在显示
@property(nonatomic, assign) BOOL showing;

///关联的cell
@property(nonatomic, weak, nullable) UIView<GKSwipeCell> *cell;

@end

@implementation GKSwipeCellHelper

+ (instancetype)helperWithCell:(UIView<GKSwipeCell> *)cell
{
    GKSwipeCellHelper *helper = [GKSwipeCellHelper new];
    helper.cell = cell;
    
    return helper;
}

- (void)setSwipeDirection:(GKSwipeDirection)swipeDirection
{
    if(swipeDirection != GKSwipeDirectionNone){
        if(!self.panGestureRecognizer){
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            pan.delegate = self;
            [self.cell addGestureRecognizer:pan];
            self.panGestureRecognizer = pan;
        }
        self.panGestureRecognizer.enabled = YES;
    }else{
        self.panGestureRecognizer.enabled = NO;
    }
}

- (void)setSwipeShow:(BOOL)show direction:(GKSwipeDirection)direction animated:(BOOL)animated
{
    if(self.showing == show || !(self.cell.swipeDirection & direction)){
        return;
    }
    
    if(show){
        [self showSnapShotViewIfNeeded];
        [self showSwipeButtonsIfNeededForDirection:direction];
        [self showSWipeButtonsAnimated:animated];
    }else{
        if(self.snapshotView){
            [self hideSwipeButtonsAnimated:animated];
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if(!newSuperview){
        [self setSwipeShow:NO direction:self.currentDirection animated:NO];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(!newWindow){
        [self setSwipeShow:NO direction:self.currentDirection animated:NO];
    }
}

// MARK: - Action

///点击快照
- (void)handleTapSnapshot
{
    [self hideSwipeButtonsAnimated:YES];
}

///平移
- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    if(pan.state == UIGestureRecognizerStateBegan && self.showing){
        CGPoint translation = [pan translationInView:self.cell];
        [pan setTranslation:CGPointMake(self.maxTranslationX + translation.x, translation.y) inView:self.cell];
    }
    
    self.translationX = [pan translationInView:self.cell].x;
    GKSwipeDirection direction = self.translationX < 0 ? GKSwipeDirectionLeft : GKSwipeDirectionRight;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan :
        case UIGestureRecognizerStateChanged : {
            [self showSnapShotViewIfNeeded];
            [self showSwipeButtonsIfNeededForDirection:direction];
            [self layoutExtraViews];
        }
            break;
        case UIGestureRecognizerStateEnded :
        case UIGestureRecognizerStateCancelled : {
            //通过速度获取可能移到的位置
            CGFloat translationX = self.translationX + [pan velocityInView:self.cell].x * 0.490750;
            BOOL show = YES;
            switch (self.currentDirection) {
                case GKSwipeDirectionLeft :
                    show = translationX < self.maxTranslationX / 2;
                    break;
                case  GKSwipeDirectionRight :
                    show = translationX > self.maxTranslationX / 2;
                    break;
                default:
                    break;
            }
            
            if(show){
                [self showSWipeButtonsAnimated:YES];
            }else{
                [self hideSwipeButtonsAnimated:YES];
            }
        }
            break;
        default:
            break;
    }
}

// MARK: - Pan

///显示快照
- (void)showSnapShotViewIfNeeded
{
    if(self.showing)
        return;
    
    if([self.cell isKindOfClass:UITableViewCell.class]){
        UITableViewCell *cell = (UITableViewCell*)self.cell;
        cell.highlighted = NO;
        cell.selected = NO;
    }else if([self.cell isKindOfClass:UICollectionViewCell.class]){
        UICollectionViewCell *cell = (UICollectionViewCell*)self.cell;
        cell.highlighted = NO;
    }
    
    self.showing = YES;
    if(!self.snapshotView){
        self.snapshotView = [UIImageView new];
        self.snapshotView.userInteractionEnabled = YES;
        [self.snapshotView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSnapshot)]];
        [self.cell addSubview:self.snapshotView];
    }
    
    [self.cell bringSubviewToFront:self.snapshotView];
    self.snapshotView.frame = self.cell.bounds;
    self.snapshotView.image = [UIImage gkImageFromView:self.cell];
    
    for(UIView *view in self.cell.subviews){
        if(view != self.snapshotView){
            view.hidden = YES;
        }
    }
    
    //添加覆盖物，防止多个滑动事件
    UIView *container = nil;
    Class cls = [self containerClass];
    UIView *view = self.cell.superview;
    while (view != nil) {
        if([view isKindOfClass:cls]){
            container = view;
            break;
        }
        view = view.superview;
    }
    
    if(!self.overlay){
        self.overlay = [[GKSwipeOverlay alloc] initWithFrame:container.bounds];
        [container addSubview:self.overlay];
    }
    self.overlay.cell = self.cell;
}

- (Class)containerClass
{
    if([self.cell isKindOfClass:UITableViewCell.class]){
        return UITableView.class;
    }else if([self.cell isKindOfClass:UICollectionViewCell.class]){
        return UICollectionView.class;
    }
    
    return UIView.class;
}

///显示按钮
- (void)showSwipeButtonsIfNeededForDirection:(GKSwipeDirection) direction
{
    if(direction != self.currentDirection){
        
        self.currentDirection = direction;
        NSAssert(self.cell.delegate != nil, @"%@ delegate must not be nil", NSStringFromClass(self.cell.class));
        for(GKSwipeItem *item in self.currentSwipeItems){
            [item.view removeFromSuperview];
        }
        
        CGFloat buttonTotalWidth = 0;
        if(self.cell.swipeDirection & direction){
            NSArray *buttons = [self.cell.delegate swipeCell:self.cell swipeButtonsForDirection:direction];
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:buttons.count];
            for(UIView *view in buttons){
                [items addObject:[GKSwipeItem itemWithView:view]];
            }
            self.currentSwipeItems = items;

            NSEnumerator *enumrator = [self.currentSwipeItems objectEnumerator];
            if(self.currentDirection == GKSwipeDirectionRight){
                enumrator = self.currentSwipeItems.reverseObjectEnumerator;
            }
            for(GKSwipeItem *item in enumrator){
                UIView *view = item.view;
                [self.cell addSubview:view];
                buttonTotalWidth += view.gkWidth;
                CGRect frame = view.frame;
                frame.origin.y = 0;
                frame.size.height = self.cell.gkHeight;
                
                switch (self.currentDirection) {
                    case GKSwipeDirectionLeft :
                        frame.origin.x = self.cell.gkWidth;
                        break;
                    case GKSwipeDirectionRight :
                        frame.origin.x = self.cell.gkLeft - view.gkWidth;
                        break;
                    default:
                        break;
                }
                view.frame = frame;
                item.startFrame = frame;
            }
            
            CGFloat x = 0;
            switch (self.currentDirection) {
                case GKSwipeDirectionLeft :
                    x = self.cell.gkRight - buttonTotalWidth;
                    break;
                case GKSwipeDirectionRight :
                    x = self.cell.gkLeft;
                default:
                    break;
            }
            for(GKSwipeItem *item in self.currentSwipeItems){
                CGRect frame = item.startFrame;
                frame.origin.x = x;
                item.endFrame = frame;
                
                x += frame.size.width;
            }
            
        }else{
            self.currentSwipeItems = nil;
        }
        
        switch (self.currentDirection) {
            case GKSwipeDirectionLeft :
                self.maxTranslationX = -buttonTotalWidth;
                break;
            case GKSwipeDirectionRight :
                self.maxTranslationX = buttonTotalWidth;
                break;
            default:
                break;
        }
    }
}

- (void)hideSwipeButtonsAnimated:(BOOL) animated
{
    self.showing = NO;
    void(^completion)(BOOL) = ^(BOOL finish){
        self.currentDirection = GKSwipeDirectionNone;
        self.maxTranslationX = 0;
        self.translationX = 0;
        
        [self.overlay removeFromSuperview];
        self.overlay = nil;
        
        for(GKSwipeItem *item in self.currentSwipeItems){
            [item.view removeFromSuperview];
        }
        self.currentSwipeItems = nil;
        
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        
        for(UIView *view in self.cell.subviews){
            view.hidden = NO;
        }
    };
    
    if(self.cell.window && self.cell.superview && animated){
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.snapshotView.frame = self.cell.bounds;
            for(GKSwipeItem *item in self.currentSwipeItems){
                item.view.frame = item.startFrame;
            }
        } completion:completion];
    }else{
        completion(YES);
    }
}

- (void)showSWipeButtonsAnimated:(BOOL) animated
{
    void(^animations)(void) = ^{
        self.snapshotView.gkCenterX = self.cell.gkWidth / 2.0 + self.maxTranslationX;
        for(GKSwipeItem *item in self.currentSwipeItems){
            item.view.frame = item.endFrame;
        }
    };
    if(self.cell.window && self.cell.superview && animated){
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animations
                         completion:nil];
    }else{
        animations();
    }
}

- (void)layoutExtraViews
{
    CGFloat translationX = self.translationX;
    CGFloat extraWith = 0;
    
    //当滑动超出范围时 添加阻尼系数
    CGFloat extra = fabs(translationX) - fabs(self.maxTranslationX);
    if(extra > 0){
        extraWith = extra * 0.3;
        if(translationX < 0){
            extraWith = -extraWith;
        }
        translationX = self.maxTranslationX + extraWith;
    }
    self.snapshotView.gkCenterX = self.cell.gkWidth / 2 + translationX;
    CGFloat width = 0;
    NSEnumerator *enumrator = [self.currentSwipeItems objectEnumerator];
    if(self.currentDirection == GKSwipeDirectionRight){
        enumrator = self.currentSwipeItems.reverseObjectEnumerator;
    }
    
    for(GKSwipeItem *item in enumrator){
        CGRect frame = item.startFrame;
        CGFloat ratio = 1.0 - width / MAX(fabs(self.maxTranslationX), fabs(translationX));
        CGFloat extras = item.startFrame.size.width / self.maxTranslationX * extraWith;
        switch (self.currentDirection) {
            case GKSwipeDirectionLeft :
                frame.origin.x += ratio * translationX;
                break;
            case GKSwipeDirectionRight :
                frame.origin.x += ratio * translationX - extras;
                break;
            default:
                break;
        }
        frame.size.width += extras;
        item.view.frame = frame;
        width += frame.size.width;
    }
}

// MARK: - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer == self.panGestureRecognizer){
        if([self.cell isKindOfClass:UITableViewCell.class]){
            UITableViewCell *cell = (UITableViewCell*)self.cell;
            if(cell.isEditing){
                return NO;
            }
        }
        CGPoint translation = [self.panGestureRecognizer translationInView:self.cell];
        //垂直滑动
        if(fabs(translation.y) > fabs(translation.x)){
            return NO;
        }
        return (translation.x < 0 && (self.cell.swipeDirection & GKSwipeDirectionLeft))
        || (translation.x > 0 && (self.cell.swipeDirection & GKSwipeDirectionRight));
    }
    return YES;
}

@end
