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
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface GKDAlertViewController ()

@property (weak, nonatomic) IBOutlet GKLabel *gkLabel;

@end


@implementation GKDAlertViewController

+ (void)load
{
    [GKRouter.sharedRouter registerPath:@"/app/alert" forHandler:^UIViewController * _Nullable(GKRouteConfig * _Nonnull config) {
        return GKDAlertViewController.new;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GKAlertProps *props = [GKAlertProps defaultActionSheetProps];
    props.contentInsets = UIEdgeInsetsZero;
//    props.cornerRadius = 0;
    props.buttonHeight = 45;
    props.cancelButtonVerticalSpacing = 8;

//    self.gkLabel.contentInsets = UIEdgeInsetsMake(30, 30, 30, 30);
    self.gkLabel.selectable = YES;
    self.gkLabel.font = [UIFont boldSystemFontOfSize:13];
    self.gkLabel.userInteractionEnabled = YES;
    self.gkLabel.textAlignment = NSTextAlignmentCenter;
    self.gkLabel.backgroundColor = UIColor.systemYellowColor;
    self.gkLabel.selectedBackgroundColor = UIColor.orangeColor;
    self.gkLabel.shouldDetectURL = YES;
    self.gkLabel.numberOfLines = 2;
    self.gkLabel.canPerformActionHandler = ^BOOL(SEL  _Nonnull action, id  _Nonnull sender) {
        return YES;
    };
    //https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref

    NSString *text = @"以上为自动回复，如果想关闭或修改内容 https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref，可点击这里修改";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    [attr addAttribute:NSFontAttributeName value:self.gkLabel.font range:NSMakeRange(0, attr.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:UIColor.blueColor range:[text rangeOfString:@"点击这里"]];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = self.gkLabel.textAlignment;
    style.lineBreakMode = self.gkLabel.lineBreakMode;
    style.lineSpacing = 5;
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    self.gkLabel.attributedText = attr;
    [self.gkLabel addClickableRange:[text rangeOfString:@"点击这里"]];
    
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
