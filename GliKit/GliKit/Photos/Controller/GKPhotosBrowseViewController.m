//
//  GKPhotosBrowseViewController.m
//  GliKit
//
//  Created by 罗海雄 on 2020/5/14.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKPhotosBrowseViewController.h"
#import "UIView+GKUtils.h"
#import "UIImage+GKUtils.h"
#import "GKContainer.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKUtils.h"
#import "NSObject+GKUtils.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "SDWebImagePrefetcher.h"
#import "SDImageCache.h"
#import "UIViewController+GKSafeAreaCompatible.h"
#import "UIApplication+GKTheme.h"
#import "UIScreen+GKUtils.h"

@implementation GKPhotosBrowseModel

+ (instancetype)modelWithImage:(UIImage *)image
{
    GKPhotosBrowseModel *model = [GKPhotosBrowseModel new];
    model.image = image;
    
    return model;
}

+ (instancetype)modelWithURL:(NSString *)URL
{
    return [self modelWithURL:URL thumnbailURL:nil];
}

+ (instancetype)modelWithURL:(NSString *)URL thumnbailURL:(NSString *)thumbnailURL
{
    GKPhotosBrowseModel *model = [GKPhotosBrowseModel new];
    model.URL = [NSURL URLWithString:URL];
    if (thumbnailURL != nil) {
        model.thumbnailURL = [NSURL URLWithString:thumbnailURL];
    }
    
    return model;
}

@end

@class GKPhotosBrowseCell;

///图片浏览cell代理
@protocol GKPhotosBrowseCellDelegate<NSObject>

///单击图片
- (void)photosBrowseCellDidClick:(GKPhotosBrowseCell*) cell;

///准备要滑动关闭预览了
- (void)photosBrowseCell:(GKPhotosBrowseCell*) cell swipeForPercent:(CGFloat) percent;

@end

///图片浏览cell
@interface GKPhotosBrowseCell : UICollectionViewCell<UIScrollViewDelegate, UIGestureRecognizerDelegate>

///滚动视图，用于图片放大缩小
@property(nonatomic, readonly) UIScrollView *scrollView;

///图片
@property(nonatomic, readonly) UIImageView *imageView;

///代理
@property(nonatomic, weak) id<GKPhotosBrowseCellDelegate> delegate;

///是否满屏显示 default YES
@property(nonatomic, assign) BOOL displayInFullScreen;

///平移手势
@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

///初始位置
@property(nonatomic, readonly) CGPoint initCenter;

///重新布局图片当图片加载完成时
- (void)layoutImageAfterLoadWithAnimated:(BOOL) animated;

///计算imageView的位置大小
- (CGRect)rectFromImage:(UIImage*) image;

@end

@implementation GKPhotosBrowseCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self.contentView addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        SDWebImageActivityIndicator *indicator = [SDWebImageActivityIndicator new];
        indicator.indicatorView.color = UIColor.whiteColor;
        if(@available(iOS 13, *)){
            indicator.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
        }else{
            indicator.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        }
        _imageView.sd_imageIndicator = indicator;
        [_scrollView addSubview:_imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        [self.scrollView addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

// MARK: - Action

//双击
- (void)handleDoubleTap:(UITapGestureRecognizer*) tap
{
    if(_scrollView.zoomScale == 1.0){
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }else{
        [_scrollView setZoomScale:1.0 animated:YES];
    }
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
    [self.delegate photosBrowseCellDidClick:self];
}

- (void)handlePan:(UIPanGestureRecognizer*) pan
{
    CGPoint point = [pan translationInView:self.scrollView];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan :
            _initCenter = _imageView.center;
            break;
        case UIGestureRecognizerStateChanged : {
            _imageView.center = CGPointMake(_initCenter.x + point.x, _initCenter.y + point.y);
            CGFloat alpha = 1.0 - fabs((_imageView.center.y - _initCenter.y)) / self.gkHeight * 2;;
            [self.delegate photosBrowseCell:self swipeForPercent:alpha];
        }
            break;
        default: {
            CGPoint center = _imageView.center;
            CGFloat y = [pan velocityInView:self.scrollView].y * 0.2;
            if (fabs(center.y + y - _initCenter.y) > 100) {
                [self.delegate photosBrowseCellDidClick:self];
            } else {
                [UIView animateWithDuration:0.25 animations:^{
                    [self.delegate photosBrowseCell:self swipeForPercent:1.0];
                    self.imageView.center = self.initCenter;
                }];
            }
        }
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGestureRecognizer) {
        BOOL scrollEnabled = self.scrollView.contentSize.height > self.scrollView.gkHeight;
        
        BOOL isTop = self.scrollView.contentOffset.y <= 0;
        BOOL isBottom = fabs(self.scrollView.contentOffset.y - self.scrollView.contentSize.height + self.scrollView.gkHeight) < 1.0;
        if (isTop || (scrollEnabled && isBottom)) {
            CGPoint velocity = [_panGestureRecognizer velocityInView:self.scrollView];
            if (fabs(velocity.y) > fabs(velocity.x)) {
                if (scrollEnabled) {
                    return (isTop && velocity.y > 0) || (isBottom && velocity.y < 0);
                } else {
                    return YES;
                }
            }
        }
        
        return NO;
    } else if ([self.superclass instancesRespondToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    
    return YES;
}

// MARK: - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(_imageView.image){
        return self.imageView;
    }else{
        return nil;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //缩放完后把视图居中
    CGFloat x = (self.gkWidth - _imageView.gkWidth) / 2;
    x = x < 0 ? 0 : x;
    CGFloat y = (self.gkHeight - _imageView.gkHeight) / 2;
    y = y < 0 ? 0 : y;
    
    _imageView.center = CGPointMake(x + _imageView.gkWidth / 2.0, y + _imageView.gkHeight / 2.0);
}

- (void)layoutImageAfterLoadWithAnimated:(BOOL) animated
{
    CGRect frame;
    UIImage *image = self.imageView.image;
    if(image){
        frame = [self rectFromImage:image];
        _scrollView.contentSize = CGSizeMake(_scrollView.gkWidth, MAX(_scrollView.gkHeight, _imageView.gkHeight));
    }else{
        frame = CGRectMake(0, 0, _scrollView.gkWidth, _scrollView.gkHeight);
        _scrollView.contentSize = CGSizeZero;
    }
    
    if(animated && !self.displayInFullScreen){
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.frame = frame;
        }];
    }else{
        self.imageView.frame = frame;
    }
}

- (CGRect)rectFromImage:(UIImage*) image
{
    CGSize size = [image gkFitWithSize:CGSizeMake(_scrollView.frame.size.width, 0)];
    if (size.width > 0 && self.displayInFullScreen && size.width < self.gkWidth) {
        size.height *= self.gkWidth / size.width;
        size.width = self.gkWidth;
    }
    return CGRectMake(MAX(0, (self.gkWidth - size.width) / 2.0), MAX((self.gkHeight - size.height) / 2.0, 0), size.width, size.height);
}

@end

@interface GKPhotosBrowseViewController ()<GKPhotosBrowseCellDelegate>

///是否正在动画
@property(nonatomic, assign) BOOL isAnimating;

///图片数量及正在显示的位置
@property(nonatomic, readonly) UILabel *pageLabel;

///是否需要动画显示图片
@property(nonatomic, assign) BOOL shouldShowAnimate;

///背景
@property(nonatomic, readonly) UIView *backgroundView;

///是否滑动到可见位置
@property(nonatomic, assign) BOOL shouldScrollToVisible;

@end

@implementation GKPhotosBrowseViewController

@synthesize visibleIndex = _visibleIndex;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithImages:(NSArray<UIImage *> *)images visibleIndex:(NSInteger)visibleIndex
{
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:images.count];
    for(UIImage *image in images){
        [models addObject:[GKPhotosBrowseModel modelWithImage:image]];
    }
    return [self initWithModels:models visibleIndex:visibleIndex];
}

- (instancetype)initWithURLs:(NSArray<NSString *> *)URLs visibleIndex:(NSInteger)visibleIndex
{
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:URLs.count];
    for(NSString *URL in URLs){
        [models addObject:[GKPhotosBrowseModel modelWithURL:URL]];
    }
    return [self initWithModels:models visibleIndex:visibleIndex];
}

#pragma clang diagnostic pop

- (instancetype)initWithModels:(NSArray<GKPhotosBrowseModel *> *)models visibleIndex:(NSInteger)visibleIndex
{
    self = [super init];
    if(self){
        _models = [models copy];
        _visibleIndex = visibleIndex;
        _imageSpacing = 15;
        _displayInFullScreen = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = self.imageSpacing;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, self.imageSpacing / 2.0, 0, self.imageSpacing / 2.0);
    self.flowLayout.itemSize = UIScreen.gkMainScreen.bounds.size;
    
    self.container.safeLayoutGuide = GKSafeLayoutGuideNone;
    self.animateDuration = 0.25;
    
    self.shouldScrollToVisible = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initViews];
}

- (BOOL)shouldAdjustContentInsetForSafeArea
{
    return NO;
}

- (void)initViews
{
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.userInteractionEnabled = NO;
    [self.view addSubview:_backgroundView];
    
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self registerClass:GKPhotosBrowseCell.class];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.alwaysBounceVertical = NO;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(-self.imageSpacing / 2.0);
        make.trailing.mas_equalTo(self.imageSpacing / 2.0);
        make.top.bottom.equalTo(@0);
    }];
    
    _pageLabel = [UILabel new];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.font = [UIFont systemFontOfSize:18];
    _pageLabel.shadowColor = [UIColor blackColor];
    _pageLabel.text = [NSString stringWithFormat:@"%d/%d", (int)_visibleIndex + 1, (int)self.models.count];
    _pageLabel.hidden = YES;
    [self.view addSubview:_pageLabel];
    
    [_pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(self.gkSafeAreaLayoutGuideBottom).offset(-20);
    }];
    
    [super initViews];
}

- (void)setContentView:(UIView *)contentView
{
    //do nothing
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(self.shouldScrollToVisible && _visibleIndex > 0){
        self.shouldScrollToVisible = NO;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_visibleIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (NSUInteger)visibleIndex
{
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if(indexPath){
        return indexPath.item;
    }else{
        return _visibleIndex;
    }
}

// MARK: - Public Method

- (void)showAnimated:(BOOL)animated
{
    UIViewController *viewController = UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController;
    
    //设置使背景透明
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [viewController presentViewController:self animated:NO completion:nil];
    
    if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerWillEnterFullScreen:)]){
        [self.delegate photosBrowseViewControllerWillEnterFullScreen:self];
    }
    
    self.shouldShowAnimate = animated;
    if(!animated){
        [self showCompletion];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

///显示完成
- (void)showCompletion
{
    if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerDidEnterFullScreen:)]){
        [self.delegate photosBrowseViewControllerDidEnterFullScreen:self];
    }
    
    self.view.userInteractionEnabled = YES;
    self.isAnimating = NO;
    self.pageLabel.hidden = NO;
}

- (void)dismissAimated:(BOOL)animated
{
    GKPhotosBrowseCell *cell = (GKPhotosBrowseCell*)[self.collectionView.visibleCells firstObject];
    self.backgroundView.hidden = YES;
    self.pageLabel.hidden = YES;
    
    CGRect rect = [self animatedRect];
    
    if(cell.imageView.image && animated){
        if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerWillExitFullScreen:)]){
            [self.delegate photosBrowseViewControllerWillExitFullScreen:self];
        }

        if(!CGRectIntersectsRect(self.view.frame, rect)){
            self.isAnimating = YES;
            [UIView animateWithDuration:self.animateDuration animations:^(void){
                
                cell.scrollView.zoomScale = 1.5;
                self.view.alpha = 0;
            }completion:^(BOOL finish){
                
                self.isAnimating = NO;
                [self dismiss];
                if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerDidExitFullScreen:)]){
                    [self.delegate photosBrowseViewControllerDidExitFullScreen:self];
                }
            }];
        }else{
            UIViewContentMode contentMode = UIViewContentModeScaleAspectFill;
            if(self.animatedViewHandler){
                contentMode = self.animatedViewHandler(self.visibleIndex).contentMode;
            }
            self.isAnimating = YES;
            [UIView animateWithDuration:self.animateDuration animations:^(void){
                
                cell.imageView.frame = rect;
                cell.imageView.contentMode = contentMode;
                cell.imageView.clipsToBounds = YES;
     
            }completion:^(BOOL finish){
                
                self.isAnimating = NO;
                [self dismiss];
                if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerDidExitFullScreen:)]){
                    [self.delegate photosBrowseViewControllerDidExitFullScreen:self];
                }
            }];
        }
    }else{
        [self dismiss];
        if([self.delegate respondsToSelector:@selector(photosBrowseViewControllerDidExitFullScreen:)]){
            [self.delegate photosBrowseViewControllerDidExitFullScreen:self];
        }
    }
}

///获取当前动画需要的rect
- (CGRect)animatedRect
{
    CGRect rect = CGRectZero;
    if(self.animatedViewHandler){
        UIView *view = self.animatedViewHandler(self.visibleIndex);
        if(view.superview){
            rect = [view.superview convertRect:view.frame toView:self.view];
        }
    }
    
    return rect;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

// MARK: - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GKPhotosBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKPhotosBrowseCell.gkNameOfClass forIndexPath:indexPath];
    
    cell.displayInFullScreen = self.displayInFullScreen;
    cell.scrollView.zoomScale = 1.0;
    cell.scrollView.contentSize = cell.bounds.size;
    
    GKPhotosBrowseModel *model = self.models[indexPath.item];
    WeakObj(self)
    
    if(model.image){
        [cell.imageView sd_cancelCurrentImageLoad];
        cell.imageView.image = model.image;
        if(!self.shouldShowAnimate){
            [cell layoutImageAfterLoadWithAnimated:NO];
        }
    }else{

        BOOL hasThumbnail = model.thumbnailURL && [SDImageCache.sharedImageCache diskImageDataExistsWithKey:model.thumbnailURL.absoluteString];
        BOOL hasImage = [SDImageCache.sharedImageCache diskImageDataExistsWithKey:model.URL.absoluteString];
        
        __block UIImage *placeholderImage = nil;
        //加载缩率图
        if(!hasImage && hasThumbnail){
            //同步加载
            [cell.imageView sd_setImageWithURL:model.thumbnailURL
                              placeholderImage:nil
                                       options:SDWebImageQueryDiskDataSync | SDWebImageQueryMemoryDataSync
                                     completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                placeholderImage = image;
                if(!selfWeak.shouldShowAnimate){
                    [cell layoutImageAfterLoadWithAnimated:NO];
                }
            }];
        }
        
        //加载原图
        [cell.imageView sd_setImageWithURL:model.URL
                          placeholderImage:placeholderImage
                                   options:SDWebImageAvoidAutoSetImage
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if(image){
                if ([imageURL.absoluteString isEqualToString:cell.imageView.sd_imageURL.absoluteString]) {
                    cell.imageView.image = image;
                    //网络图片才动画
                    if (!selfWeak.shouldShowAnimate) {
                        [cell layoutImageAfterLoadWithAnimated:cacheType == SDImageCacheTypeNone];
                    }
                }
            }
        }];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.shouldShowAnimate){
        self.shouldShowAnimate = NO;
        
        UIImage *image = nil;
        GKPhotosBrowseModel *model = self.models[indexPath.item];
        if(model.image){
            image = model.image;
        }else{
            image = [SDImageCache.sharedImageCache imageFromCacheForKey:model.URL.absoluteString];
            if(!image){
                image = [SDImageCache.sharedImageCache imageFromCacheForKey:model.thumbnailURL.absoluteString];
            }
        }
        
        GKPhotosBrowseCell *cell1 = (GKPhotosBrowseCell*)cell;
        if(image){
            self.view.userInteractionEnabled = NO;
            
            CGRect frame = [cell1 rectFromImage:image];
            CGRect rect = [self animatedRect];
            
            cell1.imageView.frame = rect;
            
            self.isAnimating = YES;
            [UIView animateWithDuration:self.animateDuration animations:^(void){
                
                cell1.imageView.image = image;
                cell1.imageView.frame = frame;
            }completion:^(BOOL finish){
                
                [cell1 layoutImageAfterLoadWithAnimated:NO];
                [self showCompletion];
            }];
        }else{
            [self showCompletion];
        }
    }
    
    [self prefetchImageForIndex:indexPath.item - 1];
    [self prefetchImageForIndex:indexPath.item + 1];
}

///预加载图片
- (void)prefetchImageForIndex:(NSInteger) index
{
    if(index >= 0 && index < self.models.count){
        GKPhotosBrowseModel *model = self.models[index];
        if(model.URL){
            [SDWebImagePrefetcher.sharedImagePrefetcher prefetchURLs:@[model.URL]];
        }
    }
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.bounds.origin.x / scrollView.gkWidth;
    _pageLabel.text = [NSString stringWithFormat:@"%d/%d", (int)index + 1, (int)self.models.count];
}

// MARK: - GKPhotosBrowseCellDelegate

- (void)photosBrowseCellDidClick:(GKPhotosBrowseCell *)cell
{
    if(self.isAnimating)
        return;
    
    [self dismissAimated:YES];
}

- (void)photosBrowseCell:(GKPhotosBrowseCell *)cell swipeForPercent:(CGFloat)percent
{
    self.pageLabel.hidden = percent < 1.0;
    self.backgroundView.alpha = percent;
}

@end
