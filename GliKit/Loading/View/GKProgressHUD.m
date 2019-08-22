//
//  GKProgressHUD.m
//  Zegobird
//
//  Created by 罗海雄 on 2019/3/19.
//  Copyright © 2019 xiaozhai. All rights reserved.
//

#import "GKProgressHUD.h"
#import "NSString+GKUtils.h"
#import "UIColor+GKUtils.h"
#import "UIView+GKUtils.h"

///垂直间距
static const CGFloat GKProgressHUDVerticalSpacing = 12.0f;

///水平间距
static const CGFloat GKProgressHUDHorizontalSpacing = 12.0f;

///文字间距
static const CGFloat GKProgressHUDLabelSpacing = 8.0f;

@interface GKProgressHUD ()

///文字大小
@property(nonatomic,assign) CGSize textSize;

///字体
@property(nonatomic,strong) UIFont *font;

///提示框最小
@property(nonatomic,assign) CGSize minimumSize;

///提示框最大
@property(nonatomic,assign) CGSize maximumSize;

///计时器延迟
@property(nonatomic,strong) NSTimer *timer;

@end

@implementation GKProgressHUD

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize imageView = _imageView;
@synthesize delay = _delay;
@synthesize dismissHandler = _dismissHandler;
@synthesize status = _status;
@synthesize text = _text;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.font = [UIFont systemFontOfSize:13];
        self.minimumSize = CGSizeMake(200, 116);
        self.maximumSize = CGSizeMake(200, 300);
        self.status = GKProgressHUDStatusNone;
        self.hidden = YES;
    }
    
    return self;
}

- (UIActivityIndicatorView*)activityIndicatorView
{
    if(!_activityIndicatorView){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_translucentView addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}

- (UIImageView*)imageView
{
    if(!_imageView){
        _imageView = [UIImageView new];
        [_translucentView addSubview:_imageView];
    }
    
    return _imageView;
}

///获取当前图标
- (UIImage*)currentImaage
{
    switch (self.status) {
        case GKProgressHUDStatusSuccess : {
            return [UIImage imageNamed:@"pop_icon_success_default"];
        }
            break;
        case GKProgressHUDStatusError : {
            return [UIImage imageNamed:@"pop_icon_error_default"];
        }
            break;
        case GKProgressHUDStatusWarning : {
            return [UIImage imageNamed:@"pop_icon_warning_default"];
        }
            break;
        default:
            return nil;
            break;
    }
}

///初始化
- (void)initViews
{
    if(!_translucentView){
        _translucentView = [[UIView alloc] init];
        _translucentView.layer.cornerRadius = 14.0f;
        _translucentView.layer.masksToBounds = YES;
        _translucentView.backgroundColor = [UIColor gkColorWithRed:50 green:50 blue:50 alpha:0.7];
        [self addSubview:_translucentView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = self.font;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.text = _text;
        _textLabel.numberOfLines = 0;
        [_translucentView addSubview:_textLabel];
    }
}

///延迟显示
- (void)delayShow
{
    [self initViews];
    _translucentView.hidden = NO;
     [self.activityIndicatorView startAnimating];
    [self adjustViews];
}

//MARK: timer

///开始计时器
- (void)startTimerWithInterval:(NSTimeInterval) interval
{
    [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

///停止计时器
- (void)stopTimer
{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

///倒计时
- (void)onTimer:(id) sender
{
    [self stopTimer];
    switch (self.status) {
        case GKProgressHUDStatusLoading : {
            [self delayShow];
        }
            break;
        case GKProgressHUDStatusSuccess :
        case GKProgressHUDStatusError :
        case GKProgressHUDStatusWarning : {
            [self dismiss];
        }
        default:
            break;
    }
}

//MARK: property

- (void)setText:(NSString *)text
{
    if(![_text isEqualToString:text]){
        _text = [text copy];
        _textSize = [_text gkStringSizeWithFont:self.font contraintWith:self.maximumSize.width - GKProgressHUDHorizontalSpacing * 2];
        _textSize.width = ceil(_textSize.width);
        _textSize.height = ceil(_textSize.height);
        
        if(_textSize.width < self.maximumSize.width - GKProgressHUDHorizontalSpacing * 2){
            _textSize.width = self.maximumSize.width - GKProgressHUDHorizontalSpacing * 2;
        }
        
        if(_textSize.height > self.maximumSize.height){
            _textSize.height = self.maximumSize.height;
        }
        if(_textLabel){
            _textLabel.text = _text;
        }
    }
}

- (void)setStatus:(GKProgressHUDStatus)status
{
    if(_status != status){
        _status = status;
        switch (_status) {
            case GKProgressHUDStatusError :
            case GKProgressHUDStatusSuccess :
            case GKProgressHUDStatusWarning : {
                [self initViews];
                self.userInteractionEnabled = NO;
                self.hidden = NO;
                self.imageView.hidden = NO;
                _translucentView.hidden = NO;
                [_activityIndicatorView stopAnimating];
                self.imageView.image = [self currentImaage];
                self.imageView.bounds = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            }
                break;
            case GKProgressHUDStatusLoading : {
                
                self.userInteractionEnabled = YES;
                self.hidden = NO;
                _imageView.hidden = YES;
            }
                break;
            case GKProgressHUDStatusNone : {
                self.hidden = YES;
            }
                break;
            default:
                break;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustViews];
}

///调整视图大小
- (void)adjustViews
{
    if(_translucentView && self.status != GKProgressHUDStatusNone && !CGSizeEqualToSize(CGSizeZero, self.bounds.size)){
        
        BOOL imageUse = self.status == GKProgressHUDStatusError || self.status == GKProgressHUDStatusSuccess || self.status == GKProgressHUDStatusWarning;
        BOOL indicatorUse = self.status == GKProgressHUDStatusLoading;
        BOOL textUse = ![NSString isEmpty:self.text];
        
        CGFloat realContentWidth = GKProgressHUDHorizontalSpacing * 2;
        CGFloat realConetnHeight = 0;
        if(imageUse){
            realConetnHeight += self.imageView.gkHeight;
            realContentWidth = MAX(textUse ? self.textSize.width : 0, self.imageView.gkWidth);
            
        }else if(indicatorUse){
            realConetnHeight += self.activityIndicatorView.gkHeight;
            realContentWidth = MAX(textUse ? self.textSize.width : 0, self.activityIndicatorView.gkWidth);
        }
        
        if(textUse){
            realConetnHeight += GKProgressHUDLabelSpacing + self.textSize.height;
        }
        
        CGFloat contentWidth = MAX(realContentWidth, self.minimumSize.width);
        CGFloat contentHeight = MAX(self.minimumSize.height, realConetnHeight + GKProgressHUDVerticalSpacing * 2);
        
        CGRect rect = CGRectMake((self.gkWidth - contentWidth) / 2.0, (self.gkHeight - contentHeight) / 2.0, contentWidth, contentHeight);
        self.translucentView.frame = rect;
        
        CGFloat y = (contentHeight - realConetnHeight) / 2;
        if(imageUse){
            self.imageView.center = CGPointMake(contentWidth / 2, y + self.imageView.gkHeight / 2.0);
            y += self.imageView.gkHeight;
        }else if (indicatorUse){
            self.activityIndicatorView.center = CGPointMake(contentWidth / 2, y + self.activityIndicatorView.gkHeight / 2.0);
            y += self.activityIndicatorView.gkHeight;
        }
        
        if(textUse){
            self.textLabel.frame = CGRectMake((contentWidth - realContentWidth) / 2, y + GKProgressHUDLabelSpacing, self.textSize.width, self.textSize.height);
        }
    }
}

//MARK: Public

- (void)show
{
    if(_status != GKProgressHUDStatusNone){
        switch (_status) {
            case GKProgressHUDStatusError :
            case GKProgressHUDStatusSuccess :
            case GKProgressHUDStatusWarning : {
                [self startTimerWithInterval:self.delay];
            }
                break;
            case GKProgressHUDStatusLoading : {
                
                //如果本身已经显示了，就不要延迟了
                if(self.delay > 0 && (!_translucentView || _translucentView.hidden)){
                    _translucentView.hidden = YES;
                    [self startTimerWithInterval:self.delay];
                }else{
                    [self delayShow];
                }
            }
                break;
            default:
                break;
        }
        [self adjustViews];
    }
}

- (void)dismissProgress
{
    if(self.status == GKProgressHUDStatusLoading){
        [self dismiss];
    }
}

///关闭
- (void)dismiss
{
    [self stopTimer];
    [UIView animateWithDuration:0.25 animations:^(void){
        
        self.translucentView.alpha = 0;
        
    }completion:^(BOOL finish){
        self.hidden = YES;
        !self.dismissHandler ?: self.dismissHandler();
    }];
}

@end
