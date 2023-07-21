//
//  GKDProgressViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/27.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDProgressViewController.h"
#import <GKProgressView.h>

@interface GKDProgressViewController ()

///xx
@property(nonatomic, strong) GKProgressView *straightLineProgressView;

///xx
@property(nonatomic, strong) GKProgressView *circleProgressView;

///xx
@property(nonatomic, strong) GKProgressView *roundCakesFromEmptyProgressView;

///xx
@property(nonatomic, strong) GKProgressView *roundCakesFromFullProgressView;

///xx
@property(nonatomic, strong) UIButton *startButton;

///计时器
@property(nonatomic, strong) NSTimer *timer;

///xx
@property(nonatomic, assign) CGFloat progress;

@end

@implementation GKDProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"进度条";
    
    GKProgressView *view = [[GKStraightLineProgressView alloc] init];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.top.equalTo(self.gkSafeAreaLayoutGuideTop).offset(15);
        make.trailing.mas_equalTo(-15);
        make.height.equalTo(@3);
    }];
    self.straightLineProgressView = view;
    
    CGFloat margin = 15;
    CGFloat width = floor((UIScreen.gkWidth - margin * 5) / 3.0);
    
    GKCircleProgressView *progressView = [[GKCircleProgressView alloc] init];
    progressView.showPercent = YES;
    view = progressView;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.top.equalTo(self.straightLineProgressView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    self.circleProgressView = view;
    
    view = [[GKRoundCakesProgressView alloc] init];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.circleProgressView.mas_trailing).offset(margin);
        make.top.equalTo(self.circleProgressView);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    self.roundCakesFromEmptyProgressView = view;
    
    GKRoundCakesProgressView *roundCatesView = [[GKRoundCakesProgressView alloc] init];
    roundCatesView.fromZero = NO;
    roundCatesView.innerMargin = 10;
    roundCatesView.layer.cornerRadius = width / 2;
    roundCatesView.layer.masksToBounds = YES;
    roundCatesView.layer.borderWidth = 5;
    roundCatesView.layer.borderColor = roundCatesView.progressColor.CGColor;
    view = roundCatesView;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.roundCakesFromEmptyProgressView.mas_trailing).offset(margin);
        make.top.equalTo(self.roundCakesFromEmptyProgressView);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    self.roundCakesFromFullProgressView = view;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn setTitle:@"停止" forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(handleProgress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.roundCakesFromFullProgressView.mas_bottom).offset(30);
    }];
    self.startButton = btn;
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)handleProgress
{
    if(self.startButton.selected){
        [self.timer invalidate];
        self.timer = nil;
    }else{
        self.progress = 0;
        WeakObj(self)
        if (@available(iOS 10.0, *)) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                selfWeak.progress += 0.1;
                selfWeak.straightLineProgressView.progress = selfWeak.progress;
                selfWeak.circleProgressView.progress = selfWeak.progress;
                selfWeak.roundCakesFromEmptyProgressView.progress = selfWeak.progress;
                selfWeak.roundCakesFromFullProgressView.progress = selfWeak.progress;
                
                if(selfWeak.progress >= 1.0){
                    selfWeak.progress = 0;
                }
            }];
        } else {
            
        }
    }
    self.startButton.selected = !self.startButton.selected;
}



@end
