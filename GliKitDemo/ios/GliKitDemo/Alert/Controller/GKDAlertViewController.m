//
//  GKDAlertViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/12/10.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDAlertViewController.h"
#import <GKAlertUtils.h>
#import <GKLabel.h>
#import <GKAlertController.h>

@interface AppearanceView : UIView

@property(nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

@property(readonly, nonatomic) UILabel *label;

@end

@implementation AppearanceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.redColor;
        _label = [UILabel new];
        _label.text = @"文字";
        _label.textColor = self.textColor;
        [self addSubview:_label];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
    }
    return self;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _label.textColor = _textColor;
}


@end

@interface GKDAlertViewController ()

@property (weak, nonatomic) IBOutlet GKLabel *gkLabel;

@end

@implementation GKDAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.gkLabel.contentInsets = UIEdgeInsetsMake(30, 30, 30, 30);
    self.gkLabel.selectable = YES;
    self.gkLabel.userInteractionEnabled = YES;
    self.gkLabel.backgroundColor = UIColor.systemYellowColor;
    self.gkLabel.selectedBackgroundColor = UIColor.orangeColor;
    self.gkLabel.shouldDetectURL = YES;
    self.gkLabel.canPerformActionHandler = ^BOOL(SEL  _Nonnull action, id  _Nonnull sender) {
        return YES;
    };
    self.gkLabel.text = @"这个一个百度链接https://www.baidu.com";
    
    self.alertButton.imagePosition = GKButtonImagePositionTop;
    
    self.titleButton.imagePosition = GKButtonImagePositionTop;
    self.imageButton.imagePosition = GKButtonImagePositionBottom;
    
    self.label.highlightedTextColor = [UIColor redColor];
    self.label.enabled = NO;
    
    [self.imageView gkSetTintColor:UIColor.grayColor forState:UIControlStateHighlighted];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView)]];
    
    [self.label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLabel)]];
}

- (IBAction)handleSystemAlert:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"信息" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleTapImageView
{
    
}

- (void)handleTapLabel
{
    
}

- (IBAction)handleAlert:(id)sender
{
    WeakObj(self)
    [GKAlertUtils showAlertWithTitle:@"这是一个Alert标题" message:@"这是一个Alert副标题" icon:[UIImage imageNamed:@"swift"] buttonTitles:@[@"取消", @"确定"] destructiveButtonIndex:1 handler:^(NSInteger buttonIndex, NSString * _Nonnull title) {
       
        [selfWeak gkShowSuccessWithText:[NSString stringWithFormat:@"点击%@了", title]];
    }];
}

- (IBAction)handleActionSheet:(id)sender
{
    WeakObj(self)
    NSArray *titles = @[@"取消", @"确定", @"不能点的"];
    GKAlertController *alert = [[GKAlertController alloc] initWithTitle:@"这是一个Alert标题" message:@"这是一个Alert副标题" icon:[UIImage imageNamed:@"swift"] style:GKAlertControllerStyleActionSheet cancelButtonTitle:@"取消" otherButtonTitles:titles];
    alert.destructiveButtonIndex = 1;
    alert.alertActions[titles.count - 1].enable = NO;
    alert.selectionHandler = ^(NSUInteger index) {
        NSString *title = index < titles.count ? titles[index] : @"取消";
        [selfWeak gkShowSuccessWithText:[NSString stringWithFormat:@"点击%@了", title]];
    };
    [alert show];
}

@end
