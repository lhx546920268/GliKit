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
#import "GKDialogViewController.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GKUtils.h>
#import <GKKVOHelper.h>
#import <GKObject.h>

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

@interface KVOTest : GKObject
{
    int _value;
}

///
@property(nonatomic, strong) NSString *name;

///
@property(nonatomic, assign) int value;

///
@property(nonatomic, readonly) NSString *readonlyValue;

@end

@interface KVOTest()

@property(nonatomic, copy) NSString *readonlyValue;

@end

@implementation KVOTest

@end

@interface GKDAlertViewController ()

@property (weak, nonatomic) IBOutlet GKLabel *gkLabel;

///
@property(nonatomic, strong) KVOTest *test;

///
@property(nonatomic, strong) NSMutableSet *blocks;

///
@property(nonatomic, copy) void(^callback)(void);

@end

@implementation GKDAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.test = [KVOTest new];
    [self.test.kvoHelper addObserver:self callback:^(NSString * _Nonnull keyPath, id  _Nullable newValue, id  _Nullable oldValue) {
        NSLog(@"%@, %@, %@", keyPath, newValue, oldValue);
    } forKeyPath:@"name"];

//    self.gkLabel.contentInsets = UIEdgeInsetsMake(30, 30, 30, 30);
    self.gkLabel.selectable = YES;
    self.gkLabel.userInteractionEnabled = YES;
    self.gkLabel.backgroundColor = UIColor.systemYellowColor;
    self.gkLabel.selectedBackgroundColor = UIColor.orangeColor;
    self.gkLabel.shouldDetectURL = YES;
    self.gkLabel.canPerformActionHandler = ^BOOL(SEL  _Nonnull action, id  _Nonnull sender) {
        return YES;
    };
    self.gkLabel.text = @"这个一个百度链接https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref";
    
    self.alertButton.imagePosition = GKButtonImagePositionTop;
    
    self.titleButton.imagePosition = GKButtonImagePositionTop;
    self.imageButton.imagePosition = GKButtonImagePositionBottom;
    
    self.label.highlightedTextColor = [UIColor redColor];
    self.label.enabled = NO;
    
    [self.imageView gkSetTintColor:UIColor.grayColor forState:UIControlStateHighlighted];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView)]];
    
    [self.label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLabel)]];
    
    
    UIImage *image = [UIImage gkQRCodeImageWithString:@"xxx" correctionLevel:GKQRCodeImageCorrectionLevelPercent7 size:CGSizeMake(100, 100) contentColor:UIColor.redColor backgroundColor:nil logo:nil logoSize:CGSizeZero];
    self.imageView.image = image;
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
}

- (IBAction)handleSystemAlert:(id)sender {
    
    self.test.name = @"xx";
    self.test.value = 1;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"信息" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)handleSystemActionSheet:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"信息" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];}

- (void)handleTapImageView
{
    self.test.name = @"11";
    self.test.value = 2;
    [GKDialogViewController.new showAsDialogInViewController:self layoutHandler:nil];
}

- (void)handleTapLabel
{
    [GKDialogViewController.new showAsDialog];
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
    GKAlertController *alert = [[GKAlertController alloc] initWithTitle:@"这是一个Alert标题" message:@"这是一个Alert副标题" icon:[UIImage imageNamed:@"swift"] style:GKAlertStyleActionSheet cancelButtonTitle:@"取消" otherButtonTitles:titles];
    alert.destructiveButtonIndex = 1;
    alert.alertActions[titles.count - 1].enabled = NO;
    alert.selectHandler = ^(NSUInteger index) {
        NSString *title = index < titles.count ? titles[index] : @"取消";
        [selfWeak gkShowSuccessWithText:[NSString stringWithFormat:@"点击%@了", title]];
    };
    [alert show];
}

@end
