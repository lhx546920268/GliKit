//
//  GKDataControl.h
//  GliKit
//
//  Created by 罗海雄 on 2019/8/20.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDataControl.h"

@interface GKDataControl()

///标题
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, NSString*> *titles;

@end

@implementation GKDataControl

- (instancetype)initWithScrollView:(UIScrollView*) scrollView
{
    CGRect frame = scrollView.bounds;
    frame.size.height = 0;
    
    self = [super initWithFrame:frame];
    if(self){
        _scrollView = scrollView;
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _originalContentInset = _scrollView.contentInset;
    self.loadingDelay = 0.4;
    self.stopDelay = 0.25;
    self.shouldDisableScrollViewWhenLoading = NO;
    self.backgroundColor = _scrollView.backgroundColor;
    
    self.titles = [NSMutableDictionary dictionary];
}

//将要添加到父视图中
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if(newSuperview){
        //添加 滚动位置更新监听
        [newSuperview addObserver:self forKeyPath:GKDataControlOffset options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeFromSuperview
{
    [self.superview removeObserver:self forKeyPath:GKDataControlOffset];
    [super removeFromSuperview];
}

// MARK: - dealloc

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}

// MARK: - public method

- (void)startLoading
{
    
}

- (void)stopLoading
{
    if(self.stopDelay){
        [self performSelector:@selector(onStopLoading) withObject:nil afterDelay:self.stopDelay];
    }else{
        [self onStopLoading];
    }
}

- (void)onStopLoading
{
    [UIView animateWithDuration:0.25 animations:^(void){
        
         [self.scrollView setContentInset:self.originalContentInset];
     }completion:^(BOOL finish){
         
         [self setState:GKDataControlStateNormal];
         self.scrollView.userInteractionEnabled = YES;
     }];
}

- (void)onStartLoading
{
    !self.handler ?: self.handler();
}

- (void)setState:(GKDataControlState)state
{
    if(_state != state){
        _state = state;
        [self onStateChange:state];
        
        switch (_state) {
            case GKDataControlStateLoading : {
                if(self.shouldDisableScrollViewWhenLoading){
                    self.scrollView.userInteractionEnabled = NO;
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)onStateChange:(GKDataControlState)state
{
    
}

- (void)setTitle:(NSString *)title forState:(GKDataControlState)state
{
    [self.titles setObject:title forKey:@(state)];
    [self onStateChange:self.state];
}

- (NSString*)titleForState:(GKDataControlState)state
{
    NSString *title = [self.titles objectForKey:@(state)];
    if(!title){
        return [self.titles objectForKey:@(GKDataControlStateNormal)];
    }
    return title;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

@end
