//
//  GKTableViewSwipeCell.m
//  GliKit
//
//  Created by 罗海雄 on 2020/12/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKTableViewSwipeCell.h"
#import "UIImage+GKUtils.h"
#import "UIView+GKUtils.h"

///滑动显示的item
@interface GKTableViewSwipeItem : NSObject

///按钮
@property(nonatomic, strong) UIView *view;

///初始位置
@property(nonatomic, assign) CGRect frame;

+ (instancetype)itemWithView:(UIView*) view;

@end

@interface GKTableViewSwipeOverlay : UIView

///关联的cell
@property(nonatomic, weak) GKTableViewSwipeCell *cell;

@end

@interface GKTableViewSwipeCell()<UIGestureRecognizerDelegate>

///平移手势
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

///内容快照
@property(nonatomic, strong) UIImageView *snapshotView;

///当前按钮
@property(nonatomic, strong) NSArray<GKTableViewSwipeItem*> *currentSwipeItems;

///滑动的最大位置
@property(nonatomic, assign) CGFloat maxTranslationX;

///当前方向
@property(nonatomic, assign) GKSwipeDirection currentDirection;

///平移量
@property(nonatomic, assign) CGFloat translationX;

///覆盖物
@property(nonatomic, strong) GKTableViewSwipeOverlay *overlay;

///是否正在显示
@property(nonatomic, assign) BOOL showing;

@end

@implementation GKTableViewSwipeItem

+ (instancetype)itemWithView:(UIView *)view
{
    GKTableViewSwipeItem *item = [GKTableViewSwipeItem new];
    item.view = view;
    
    return item;
}

@end

@implementation GKTableViewSwipeOverlay

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self.cell.superview convertRect:self.cell.frame toView:self];
    if(CGRectContainsPoint(rect, point)){
        return nil;
    }
    
    [self.cell setSwipeShow:NO direction:self.cell.currentDirection animated:YES];
    
    //不阻塞cell的事件
    UITableView *tableView = (UITableView*)self.superview;
    NSArray *cells = [tableView visibleCells];
    for(UITableViewCell *cell in cells){
        CGRect rect = [cell.superview convertRect:cell.frame toView:self];
        if(CGRectContainsPoint(rect, point)){
            return cell;
        }
    }
    
    return [super hitTest:point withEvent:event];;
}

@end

@implementation GKTableViewSwipeCell

- (void)setSwipeDirection:(GKSwipeDirection)swipeDirection
{
    if(_swipeDirection != swipeDirection){
        _swipeDirection = swipeDirection;
        if(_swipeDirection != GKSwipeDirectionNone){
            if(!self.panGestureRecognizer){
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
                pan.delegate = self;
                [self addGestureRecognizer:pan];
                self.panGestureRecognizer = pan;
            }
            self.panGestureRecognizer.enabled = YES;
        }else{
            self.panGestureRecognizer.enabled = NO;
        }
    }
}

- (void)setSwipeShow:(BOOL)show direction:(GKSwipeDirection)direction animated:(BOOL)animated
{
    if(self.showing == show || !(self.swipeDirection & direction)){
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

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(!newWindow){
        [self setSwipeShow:NO direction:GKSwipeDirectionLeft animated:NO];
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
    CGPoint translation = [pan translationInView:self];
    self.translationX = translation.x;
    GKSwipeDirection direction = translation.x < 0 ? GKSwipeDirectionLeft : GKSwipeDirectionRight;
    
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
            if(fabs(self.snapshotView.gkCenterX - self.gkWidth) > fabs(self.maxTranslationX / 2)){
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
    
    self.editing = NO;
    self.showing = YES;
    if(!self.snapshotView){
        self.snapshotView = [UIImageView new];
        self.snapshotView.userInteractionEnabled = YES;
        [self.snapshotView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSnapshot)]];
        [self addSubview:self.snapshotView];
    }
    
    self.snapshotView.hidden = NO;
    self.snapshotView.frame = self.bounds;
    self.snapshotView.image = [UIImage gkImageFromView:self];
    
    for(UIView *view in self.subviews){
        if(view != self.snapshotView){
            view.hidden = YES;
        }
    }
    
    //添加覆盖物，防止多个滑动事件
    UITableView *tableView = nil;
    UIView *view = self.superview;
    while (view != nil) {
        if([view isKindOfClass:UITableView.class]){
            tableView = (UITableView*)view;
            break;
        }
        view = view.superview;
    }
    
    if(!self.overlay){
        self.overlay = [[GKTableViewSwipeOverlay alloc] initWithFrame:tableView.bounds];
        [tableView addSubview:self.overlay];
    }
    self.overlay.cell = self;
}

///显示按钮
- (void)showSwipeButtonsIfNeededForDirection:(GKSwipeDirection) direction
{
    if(direction != self.currentDirection){
        
        self.currentDirection = direction;
        NSAssert(self.delegate != nil, @"%@ delegate must not be nil", NSStringFromClass(self));
        for(GKTableViewSwipeItem *item in self.currentSwipeItems){
            [item.view removeFromSuperview];
        }
        
        CGFloat buttonTotalWidth = 0;
        if(self.swipeDirection & direction){
            NSArray *buttons = [self.delegate tableViewSwipeCell:self swipeButtonsForDirection:direction];
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:buttons.count];
            for(UIView *view in buttons){
                [items addObject:[GKTableViewSwipeItem itemWithView:view]];
            }
            self.currentSwipeItems = items;

            UIView *preView = self;
            for(GKTableViewSwipeItem *item in self.currentSwipeItems){
                UIView *view = item.view;
                [self addSubview:view];
                buttonTotalWidth += view.gkWidth;
                CGRect frame = view.frame;
                frame.origin.y = 0;
                frame.size.height = self.gkHeight;
                switch (self.currentDirection) {
                    case GKSwipeDirectionLeft :
                        frame.origin.x = preView.gkRight;
                        break;
                    case GKSwipeDirectionRight :
                        frame.origin.x = preView.gkLeft - view.gkWidth;
                        break;
                    default:
                        break;
                }
                view.frame = frame;
                item.frame = frame;
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
        
        for(GKTableViewSwipeItem *item in self.currentSwipeItems){
            [item.view removeFromSuperview];
        }
        self.currentSwipeItems = nil;
        
        self.currentSwipeItems = nil;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        
        for(UIView *view in self.subviews){
            if(view != self.snapshotView){
                view.hidden = NO;
            }
        }
    };
    
    if(animated){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.snapshotView.frame = self.bounds;
            for(GKTableViewSwipeItem *item in self.currentSwipeItems){
                item.view.frame = item.frame;
            }
        } completion:completion];
    }else{
        completion(YES);
    }
}

- (void)showSWipeButtonsAnimated:(BOOL) animated
{
    void(^animations)(void) = ^{
        self.snapshotView.gkCenterX = self.gkWidth / 2.0 + self.maxTranslationX;
        CGFloat width = 0;
        for(GKTableViewSwipeItem *item in self.currentSwipeItems){
            CGRect frame = item.frame;
            frame.origin.x = item.frame.origin.x + (1.0 - width / fabs(self.maxTranslationX)) * self.maxTranslationX;
            item.view.frame = frame;
            width += item.view.gkWidth;
        }
    };
    if(animated){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:nil];
    }else{
        animations();
    }
}

- (void)layoutExtraViews
{
    CGFloat translationX = self.translationX;
    CGFloat extraWith = 0;
    //当滑动超出范围时 添加阻尼系数
    if(translationX < self.maxTranslationX){
        extraWith = (fabs(translationX) - fabs(self.maxTranslationX)) * 0.8;
        translationX = self.maxTranslationX - extraWith;
    }
    self.snapshotView.gkCenterX = self.gkWidth / 2 + translationX;
    
    CGFloat width = 0;
    for(GKTableViewSwipeItem *item in self.currentSwipeItems){
        CGRect frame = item.frame;
        CGFloat ratio = 1.0 - width / fabs(self.maxTranslationX);
        frame.origin.x += ratio * translationX;
        frame.size.width += item.frame.size.width / fabs(self.maxTranslationX) * extraWith;
        item.view.frame = frame;
        width += item.frame.size.width;
    }
}

// MARK: - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer == self.panGestureRecognizer){
        if(self.isEditing){
            return NO;
        }
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        //垂直滑动
        if(fabs(translation.y) > fabs(translation.x)){
            return NO;
        }
        return (translation.x < 0 && (self.swipeDirection & GKSwipeDirectionLeft)) || (translation.x > 0 && (self.swipeDirection & GKSwipeDirectionRight));
    }
    return YES;
}

@end
