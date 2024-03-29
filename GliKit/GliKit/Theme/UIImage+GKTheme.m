//
//  UIImage+GKTheme.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/2.
//

#import "UIImage+GKTheme.h"
#import "UIColor+GKTheme.h"
#import "UIScreen+GKUtils.h"

static UIImage *appNavigationBarBackIcon = nil;
static CGFloat appImageScale = 2.0;

@implementation UIImage (GKTheme)

+ (UIImage *)gkNavigationBarBackIcon
{
    if(!appNavigationBarBackIcon){
        UIImage *image = [UIImage imageNamed:@"back_icon"];
        if(!image){
            
            CGSize size = CGSizeMake(12, 20);
            CGFloat lineWidth = 2.0;
            UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.gkMainScreen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, lineWidth);
            CGContextSetStrokeColorWithColor(context, UIColor.gkNavigationBarTintColor.CGColor);
            
            CGContextMoveToPoint(context, size.width, 0);
            CGContextAddLineToPoint(context, lineWidth / 2.0, size.height / 2.0);
            CGContextAddLineToPoint(context, size.width, size.height);
            
            CGContextStrokePath(context);
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        //Template
        if(image.renderingMode != UIImageRenderingModeAlwaysTemplate){
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        appNavigationBarBackIcon = image;
    }
    
    return appNavigationBarBackIcon;
}

+ (void)setGkNavigationBarBackIcon:(UIImage *)gkNavigationBarBackIcon
{
    appNavigationBarBackIcon = gkNavigationBarBackIcon;
}

+ (void)setGkImageScale:(CGFloat)gkImageScale
{
    appImageScale = gkImageScale;
}

+ (CGFloat)gkImageScale
{
    return appImageScale;
}

@end
