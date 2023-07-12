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
#import "TTTAttributedLabel.h"
#import <NSAttributedString+GKUtils.h>

@implementation GKDTextContainer

- (void)layoutSubviews
{
    NSLog(@"GKDTextContainer");
    [super layoutSubviews];
}

@end

@interface GKDAlertViewController ()

@property (weak, nonatomic) IBOutlet GKLabel *gkLabel;

@end

//NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
//textContainer.lineFragmentPadding = 0;
//textContainer.lineBreakMode = self.lineBreakMode;
//textContainer.maximumNumberOfLines = self.numberOfLines;
//
//NSLayoutManager *layoutManager = [NSLayoutManager new];
//[layoutManager addTextContainer:textContainer];
//
//NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//[attr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attr.length)];
//NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//style.alignment = self.textAlignment;
//style.lineBreakMode = self.lineBreakMode;
//style.lineSpacing = 5;
//[attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attr.length)];
//NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attr];
//[textStorage addLayoutManager:layoutManager];
//textContainer.size = self.textDrawRect.size;
//
//CGRect rect = [layoutManager usedRectForTextContainer:textContainer];
//CGFloat offset = 0;
//switch (self.textAlignment) {
//    case NSTextAlignmentLeft :
//    case NSTextAlignmentNatural :
//    case NSTextAlignmentJustified :
//        offset = 0;
//        break;
//    case NSTextAlignmentCenter :
//        offset = 0.5;
//        break;
//    case NSTextAlignmentRight :
//        offset = 1.0;
//        break;
//}
//
//CGFloat offsetX = (self.textDrawRect.size.width - rect.size.width) * offset - rect.origin.x;
//CGFloat offsetY = (self.textDrawRect.size.height - rect.size.height) * offset - rect.origin.y;
//CGPoint location = CGPointMake(point.x - offsetX, point.y - offsetY);
//
//CGFloat value;
//NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:&value];
//if (value > 0) {
//                    //获取对应的可点信息
//                    for(NSValue *result in self.clickableRanges){
//                        NSRange rangeValue = result.rangeValue;
//                        if(NSLocationInRange(characterIndex, rangeValue)){
//                            range = rangeValue;
//                            break;
//                        }
//                    }
//}


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

    self.gkLabel.font = [UIFont boldSystemFontOfSize:13];
    self.gkLabel.userInteractionEnabled = YES;
//    self.gkLabel.textAlignment = NSTextAlignmentCenter;
    self.gkLabel.backgroundColor = UIColor.systemYellowColor;
    self.gkLabel.numberOfLines = 3;

        self.gkLabel.selectable = NO;
    self.gkLabel.selectedBackgroundColor = UIColor.orangeColor;
    self.gkLabel.textDetector = GKURLDetector.sharedDetector;
   
    self.gkLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.gkLabel.verticalAligment = GKLabelVerticalAligmentCenter;
    self.gkLabel.preferredMaxLayoutWidth = 340;
    self.gkLabel.contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    //https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref

    NSString *text = @"这是一个超链接https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref，点击这里修改";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    [attr addAttribute:NSFontAttributeName value:self.gkLabel.font range:NSMakeRange(0, attr.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:UIColor.blueColor range:[text rangeOfString:@"点击这里"]];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = self.gkLabel.textAlignment;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.lineSpacing = 5;
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];

    NSLog(@"size = %@", NSStringFromCGSize([attr gkBoundsWithConstraintWidth:UIScreen.gkWidth - 30]));
//    self.gkLabel.lineSpacing = 5;
//    self.gkLabel.text = text;
//    [self.gkLabel addLinkToURL:[NSURL URLWithString:@"www.baidu.com"] withRange:NSMakeRange(30, 10)];
    
    self.gkLabel.attributedText = attr;
    self.gkLabel.attributedTruncationString = [[NSAttributedString alloc] initWithString:@"...展开"];
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

    image = [UIImage gkQRCodeImageWithString:@"好东西" correctionLevel:GKQRCodeImageCorrectionLevelPercent30 size:CGSizeMake(200, 200) contentColor:UIColor.blueColor backgroundColor:UIColor.whiteColor logo:[UIImage imageNamed:@"swift"] logoSize:CGSizeMake(54, 54)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
        make.size.equalTo(200);
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
