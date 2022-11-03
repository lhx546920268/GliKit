//
//  GKDRootViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/8/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDRootViewController.h"
#import "GKDRowModel.h"
#import <GliKitDemo-Swift.h>
#import <GKAppUtils.h>
#import <NSJSONSerialization+GKUtils.h>
#import <SDWebImageDownloader.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>

@import NetworkExtension;
@import CoreText;
@import AVKit;

@interface GKParent : NSObject<NSCopying>

@property(nonatomic, copy) NSString *name;

@end

@implementation GKParent

GKConvenientCopying

@end

@interface GKChild : GKParent

@property(nonatomic, copy) NSString *childName;

@end

@implementation GKChild

@end

@interface GKDRootViewController ()<CAAnimationDelegate, UITabBarControllerDelegate, GKSwipeCellDelegate>

@property(nonatomic, strong) NSArray<GKDRowModel*> *datas;

@end

@interface CATextContainer : NSTextContainer

@end

@implementation CATextContainer
//
//- (CGSize)size
//{
//    CGSize size = [super size];
//    NSLog(@"%@", NSStringFromCGSize(size));
//    return size;
//}

@end

@interface CALayoutManager : NSLayoutManager

@end

@implementation CALayoutManager

- (CGRect)usedRectForTextContainer:(NSTextContainer *)container
{
    CGRect rect = [super usedRectForTextContainer:container];
    NSLog(@"%@", NSStringFromCGRect(rect));
//    rect.size.height += 10;
    return rect;
}

@end

@interface DemoView : UIView

@end

@implementation DemoView

- (void)drawRect:(CGRect)rect
{
    
}

@end

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface LuckyDrawView : UIView

@end

@implementation LuckyDrawView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc
{
  
}

- (void)drawRect:(CGRect)rect
{
    [UIColor.whiteColor set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 2);
    
    
    
    const CGFloat components[] = {3, 3};
    CGContextSetLineDash(context, 0, components, 2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point1 = CGPointMake(10, 10);
    CGPoint point2 = CGPointMake(20, rect.size.height / 2);
    
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
//    [path addQuadCurveToPoint:CGPointMake(rect.size.width, rect.size.height - 10) controlPoint:point2];
    
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    
    CGFloat extraAngle = atan((point2.y - point1.y) / (point2.x - point1.x));
    CGFloat angle = 30.0 / 180.0 * M_PI - extraAngle;
    
    CGFloat radius = 8;

    NSLog(@"sin %f", sin(angle) * radius);
    NSLog(@"cos %f", cos(angle) * radius);
    
    CGContextSetLineDash(context, 0, NULL, 0);
    path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:CGPointMake(point1.x + cos(angle) * radius, point1.y - sin(angle) * radius)];
    
    angle = 30.0 / 180.0 * M_PI + extraAngle;
    [path moveToPoint:point1];
    [path addLineToPoint:CGPointMake(point1.x + cos(angle) * radius, point1.y + sin(angle) * radius)];
    CGContextAddPath(context, path.CGPath);
    
    CGContextStrokePath(context);
}

@end

@interface GKDRootViewController ()

@property(nonatomic, strong) UILabel *countLabel;

@property(nonatomic, assign) NSInteger count;


///
@property(nonatomic, strong) CLGeocoder *geocoder;

@end

@interface GKDRootViewController ()

///
@property(nonatomic, copy) NSString *dir;
@property(nonatomic, copy) NSString *doc;
@property(nonatomic, copy) NSString *imageDir;
@property(nonatomic, strong) NSArray *files;

@end

@interface MyTextAttachment : NSTextAttachment

@end

@implementation MyTextAttachment


@end

@interface MYLabel : UILabel

@end

@implementation MYLabel

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
//
//    NSArray *layers = self.layer.sublayers;
//    if ([layer isKindOfClass:CATextLayer.class]) {
//        NSLog(@"%@", layer);
//    }
//    for (CALayer *layer in layers) {
//        if ([layer isKindOfClass:CATextLayer.class]) {
//            NSLog(@"%@", layer);
//        } else {
//            NSLog(@"%@", layer.sublayers);
//        }
//
//        layer.masksToBounds = YES;
//    }
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    if (size.height != UIViewNoIntrinsicMetric) {
        size.height = ceil(size.height * 1.2);
    }
    return size;
}

@end

@interface GKDRootListCell : GKTableViewSwipeCell

///
@property(nonatomic, readonly) UILabel *titleLabel;
@end

@implementation GKDRootListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [MYLabel new];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
            make.leading.equalTo(15);
        }];
    }
    
    return self;
}

@end



@implementation GKDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = GKAppUtils.appName;
    
//    UITextView *textView = [UITextView new];
//    textView.text = @"လက်ခံသူအကောင့် nomnal 粗体";
//    UIFont *font = [UIFont fontWithName:@"NotoSansMyanmar-Bold" size:15];
//    textView.font = font;
//    [self.view addSubview:textView];
//
//    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(20);
//        make.top.equalTo(150);
//        make.trailing.equalTo(-20);
//        make.height.equalTo(100);
//    }];
//
//    textView = [UITextView new];
//    textView.text = @"လက်ခံသူအကောင့် nomnal 粗体";
//    font = [UIFont fontWithName:@"Oxygen-Bold" size:15];
//    textView.font = font;
//    [self.view addSubview:textView];
//
//    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(20);
//        make.top.equalTo(280);
//        make.trailing.equalTo(-20);
//        make.height.equalTo(100);
//    }];
//
//    DemoView *view = [DemoView new];
//    [self.view addSubview:view];
//
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(0);
//    }];
//
//    dispatch_main_after(1, ^{
//        NSLog(@"%@", view.layer.contents);
//    })
    
    self.datas = @[
                   [GKDRowModel modelWithTitle:@"相册" clazz:@"user/photo"],
                   [GKDRowModel modelWithTitle:@"骨架" clazz:@"skeleton"],
                   [GKDRowModel modelWithTitle:@"过渡" clazz:@"GKDTransitionViewController"],
                   [GKDRowModel modelWithTitle:@"嵌套滑动" clazz:@"/app/nested"],
                   [GKDRowModel modelWithTitle:@"空视图" clazz:@"GKDEmptyViewController"],
                   [GKDRowModel modelWithTitle:@"进度条" clazz:@"GKDProgressViewController"],
                   [GKDRowModel modelWithTitle:@"Web" clazz:@"GKDWebViewController"],
                   [GKDRowModel modelWithTitle:@"Alert" clazz:@"GKDAlertViewController"],
                   [GKDRowModel modelWithTitle:@"扫码" clazz:@"GKScanViewController"],
                   [GKDRowModel modelWithTitle:@"Banner" clazz:@"GKDBannerViewController"],
                   [GKDRowModel modelWithTitle:@"Dynamic" clazz:@"/app/dynimic"],
                   ];

    [self initViews];
    
//    self.view.backgroundColor = UIColor.redColor;
//
//    UIImage *image = [UIImage imageNamed:@"im_bg_servicebg_white"];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    [self.view addSubview:imageView];
//
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(120);
//        make.centerX.equalTo(0);
//    }];
//
//    NSLog(@"%@", NSStringFromCGSize(image.size));
//    UIImage *image2 = [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 20, 18, 20) resizingMode:UIImageResizingModeTile];
//
//    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image2];
//    [self.view addSubview:imageView2];
//
//    [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imageView.mas_bottom).offset(20);
//        make.centerX.equalTo(0);
//        make.size.equalTo(CGSizeMake(250, 300));
//    }];

//    NSArray *familyNames = [UIFont familyNames];
//    for (NSString *familyName in familyNames) {
//        NSLog(@"%@", [UIFont fontNamesForFamilyName:familyName]);
//    }
//    self.countLabel = [UILabel new];
//    self.countLabel.text = @"0";
//    self.countLabel.font = [UIFont boldSystemFontOfSize:40];
//    [self.view addSubview:self.countLabel];
//
//    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(0);
//    }];
    
//    [self gkSetLeftItemWithTitle:@"左边" action:@selector(start)];
//
//    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    NSString *dir = [doc stringByAppendingPathComponent:@"车"];
//    NSString *imageDir = [doc stringByAppendingPathComponent:@"图片"];
//
//    NSFileManager *manager = NSFileManager.defaultManager;
//    self.files = [manager contentsOfDirectoryAtPath:dir error:nil];
//    self.dir = dir;
//    self.imageDir = imageDir;
//    self.doc = doc;
    
//    UIImage *image = [UIImage imageNamed:@"tab_cart_s"];
//    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"谢谢惠顾"];
//
//    MyTextAttachment *attachment = [MyTextAttachment new];
//    attachment.image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
//
//    NSString *str1 = @"⁡ㅤ1";
//    NSLog(@"str1 length %ld", str1.length);
//    NSMutableAttributedString *imageAttr = [[NSMutableAttributedString alloc] initWithString:str1];
////    [imageAttr appendAttributedString:[[NSAttributedString alloc] initWithString:str1]];
//
//    NSLog(@"%ld", imageAttr.length);
//
//    [attr insertAttributedString:imageAttr atIndex:0];
//
//    [attr addAttribute:NSKernAttributeName value:@15 range:NSMakeRange(0, attr.length)];
//
//    [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(0, attr.length)];
//
//    NSLayoutManager *layoutManager = [NSLayoutManager new];
//    UILabel *label = [UILabel new];
//
//    label.attributedText = attr;
//    label.backgroundColor = UIColor.redColor;
//    [self.view addSubview:label];
//
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(0);
//        make.size.equalTo(CGSizeMake(200, 80));
//    }];
//
//    NSLog(@"text length %ld", label.text.length);
//
//    LuckyDrawView *view = [LuckyDrawView new];
//    view.backgroundColor = UIColor.redColor;
//    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
//    [self.view addSubview:view];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(0);
//        make.size.equalTo(CGSizeMake(200, 80));
//    }];
    
    
//    self.geocoder = [CLGeocoder new];
    

    NSLog(@"doc %@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    NSLog(@"lib %@", NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES));
    NSLog(@"doca %@", NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES));
    NSLog(@"cache %@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
    NSLog(@"use %@", NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES));
    
    NSLog(@"home %@", NSHomeDirectory());
    NSLog(@"temp %@", NSTemporaryDirectory());
    NSLog(@"step %@", NSOpenStepRootDirectory());
}

+ (BOOL)toText
{
    NSLog(@"to text %@", @"1");
    return NO;
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
//    static CGFloat size = 100;
//    [tap.view mas_updateConstraints:^(MASConstraintMaker *make) {
//        size = size == 100 ? 50 : 100;
//        make.size.equalTo(size);
//    }];
    [UIView performSystemAnimation:UISystemAnimationDelete onViews:@[tap.view] options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
    } completion:nil];
}

- (void)start
{
    [self downloadNext];
}

- (void)downloadNext
{
    if (self.count < self.files.count) {
        [self downloadForFilename:self.files[self.count]];
        self.countLabel.text = [NSString stringWithFormat:@"%ld", self.count + 1];
    }
}

- (void)downloadForFilename:(NSString*) filename
{
    NSString *file = [self.dir stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSDictionary *dic = [NSJSONSerialization gkDictionaryFromData:data];
    NSArray *list = [[[dic gkDictionaryForKey:@"result"] gkDictionaryForKey:@"getSingleFilterInfo"] gkArrayForKey:@"pList"];
    
    NSString *imageDir = [self.imageDir stringByAppendingPathComponent:[filename stringByReplacingOccurrencesOfString:@".json" withString:@""]];
    if (![NSFileManager.defaultManager fileExistsAtPath:imageDir isDirectory:nil]) {
        if (![NSFileManager.defaultManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"下载失败 %@", filename);
            self.count ++;
            [self downloadNext];
            return;
        }
    }
    
    NSInteger count = list.count;
    if (count > 0) {
        __block NSInteger totalCount = 0;
        for (NSDictionary *dict in list) {
            NSString *icon = [dict gkStringForKey:@"icon"];
            if (![NSString isEmpty:icon]) {
                NSString *title = [dict gkStringForKey:@"text"];
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:icon] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    
                    totalCount ++;
                    if (data) {
                        NSString *suffix = [[icon componentsSeparatedByString:@"."] lastObject];
                        if ([NSString isEmpty:suffix]) {
                            suffix = @"png";
                        }
                        NSString *imageFile = [imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", title, suffix]];
                        if (![data writeToFile:imageFile atomically:YES]) {
                            NSLog(@"写入文件失败 %@ - %@", filename, title);
                        }
                    } else {
                        NSLog(@"下载失败 %@ - %@", filename, title);
                    }
                    if (totalCount >= count) {
                        self.count ++;
                        [self downloadNext];
                    }
                }];
            } else {
                totalCount ++;
            }
        }
    } else {
        NSLog(@"下载失败 %@", filename);
        self.count ++;
        [self downloadNext];
    }
}

- (void)initViews
{
    self.style = UITableViewStyleGrouped;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [self registerClass:RootListCell.class];
    [self registerClass:GKDRootListCell.class];
    [super initViews];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    NSLog(@"velocity %f %f, %f, %f", [scrollView.panGestureRecognizer velocityInView:scrollView].y, velocity.y, scrollView.contentOffset.y, targetContentOffset->y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"%f", scrollView.contentOffset.y);
}

//MARK: UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count * 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDRootListCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDRootListCell.gkNameOfClass forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    NSString *title = self.datas[indexPath.row % self.datas.count].title;
    cell.titleLabel.text = title;
    cell.titleLabel.textColor = UIColor.blackColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor = UIColor.redColor;
    cell.swipeDirection = GKSwipeDirectionLeft | GKSwipeDirectionRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"www.baidu.com"]];
//    NSString *encodedURL = [@"https://devtest.zegobird.com:11111/public/pages/coupon/index.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *str = [NSString stringWithFormat:@"zegodealer:///app/web?url=%@", encodedURL];
//    [UIApplication.sharedApplication openURL:[NSURL URLWithString:str]];
    GKDRowModel *model = self.datas[indexPath.row % self.datas.count];
    [GKRouter.sharedRouter open:^(GKRouteConfig * _Nonnull config) {
        config.path = model.className;
    }];
}

- (NSArray<UIView *> *)swipeCell:(UIView<GKSwipeCell> *)cell swipeButtonsForDirection:(GKSwipeDirection)direction
{
    UIButton *deleteBtn = [UIButton new];
    deleteBtn.backgroundColor = UIColor.redColor;
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    deleteBtn.bounds = CGRectMake(0, 0, 100, 44);
    
    UIButton *btn = [UIButton new];
    btn.backgroundColor = UIColor.blueColor;
    [btn setTitle:@"收藏" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    btn.bounds = CGRectMake(0, 0, 100, 44);
    
    
    return @[deleteBtn, btn];
}

@end
