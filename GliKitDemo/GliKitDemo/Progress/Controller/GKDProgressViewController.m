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
@property(nonatomic, assign) float progress;

@end

@implementation GKDProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"进度条";
    
    GKProgressView *view = [[GKProgressView alloc] initWithStyle:GKProgressViewStyleStraightLine];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(15);
        make.top.equalTo(self.gkSafeAreaLayoutGuideTop).offset(15);
        make.trailing.equalTo(-15);
        make.height.equalTo(3);
    }];
    self.straightLineProgressView = view;
    
    CGFloat margin = 15;
    CGFloat width = floor((UIScreen.gkScreenWidth - margin * 5) / 3.0);
    
    view = [[GKProgressView alloc] initWithStyle:GKProgressViewStyleCircle];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(15);
        make.top.equalTo(self.straightLineProgressView.mas_bottom).offset(20);
        make.size.equalTo(CGSizeMake(width, width));
    }];
    self.circleProgressView = view;
    
    view = [[GKProgressView alloc] initWithStyle:GKProgressViewStyleRoundCakesFromEmpty];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.circleProgressView.mas_trailing).offset(margin);
        make.top.equalTo(self.circleProgressView);
        make.size.equalTo(CGSizeMake(width, width));
    }];
    self.roundCakesFromEmptyProgressView = view;
    
    view = [[GKProgressView alloc] initWithStyle:GKProgressViewStyleRoundCakesFromFull];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.roundCakesFromEmptyProgressView.mas_trailing).offset(margin);
        make.top.equalTo(self.roundCakesFromEmptyProgressView);
        make.size.equalTo(CGSizeMake(width, width));
    }];
    self.roundCakesFromFullProgressView = view;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn setTitle:@"停止" forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(handleProgress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(0);
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
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
                selfWeak.progress += 0.01;
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
