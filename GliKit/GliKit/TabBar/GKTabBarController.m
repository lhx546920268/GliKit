//
//  GKTabBarController.m
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKTabBarController.h"
#import "GKTabBar.h"
#import "GKTabBarButton.h"
#import "GKContainer.h"
#import "UIColor+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKUtils.h"

@implementation GKTabBarItem

+ (instancetype)itemWithTitle:(NSString*) title normalImage:(UIImage*) normalImage viewController:(UIViewController *)viewControllr
{
    return [self itemWithTitle:title normalImage:normalImage selectedImage:nil viewController:viewControllr];
}

+ (instancetype)itemWithTitle:(NSString*) title normalImage:(UIImage*) normalImage selectedImage:(UIImage*) selectedImage viewController:(UIViewController*) viewControllr
{
    GKTabBarItem *item = [GKTabBarItem new];
    item.title = title;
    if(!selectedImage){
        ///ios7 的 imageAssets 不支持 Template
        if(normalImage.renderingMode != UIImageRenderingModeAlwaysTemplate){
            normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    item.normalImage = normalImage;
    item.selectedImage = selectedImage;
    item.viewController = viewControllr;
    
    return item;
}

@end

@interface GKTabBarController ()<GKTabBarDelegate, UINavigationControllerDelegate>

///选中的视图
@property(nonatomic,assign) NSUInteger selectedItemIndex;

///标签栏隐藏状态
@property(nonatomic, assign) BOOL tabBarHidden;

@end

@implementation GKTabBarController

@synthesize tabBar = _tabBar;
@synthesize normalColor = _normalColor;
@synthesize selectedColor = _selectedColor;
@synthesize font = _font;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _selectedIndex = NSNotFound;
        _selectedItemIndex = NSNotFound;
    }
    
    return self;
}

- (void)setItems:(NSArray<GKTabBarItem *> *)items
{
    if(_items != items){
        _items = [items copy];
        
        //创建选项卡按钮
        NSMutableArray *btns = [NSMutableArray arrayWithCapacity:_items.count];
        
        for(NSInteger i = 0;i < _items.count;i ++){
            
            //创建选项卡按钮
            GKTabBarItem *item = _items[i];
            
            if([item.viewController isKindOfClass:UINavigationController.class]){
                UINavigationController *nav = (UINavigationController*)item.viewController;
                nav.delegate = self;
            }

            GKTabBarButton *btn = [GKTabBarButton new];
            btn.textLabel.textColor = self.normalColor;
            btn.textLabel.font = self.font;
            btn.textLabel.text = item.title;
            btn.imageView.image = item.normalImage;
            [btns addObject:btn];
            
            item.viewController.gkHasTabBar = YES;
        }
        _buttons = [btns copy];
        _tabBar.buttons = _buttons;
        
        
        if(self.isViewLoaded){
            self.selectedIndex = 0;
        }
    }
}

// MARK: - public method

- (void)setBadgeValue:(NSString*) badgeValue forIndex:(NSInteger) index
{
    [self.tabBar setBadgeValue:badgeValue forIndex:index];
}

- (UIViewController*)selectedViewController
{
    if(_selectedItemIndex < _items.count){
        GKTabBarItem *item = _items[_selectedItemIndex];
        return item.viewController;
    }
    
    return nil;
}

// MARK: - 加载视图

- (GKTabBar*)tabBar
{
    if(!_tabBar){
        _tabBar = [[GKTabBar alloc] initWithButtons:self.buttons];
        _tabBar.delegate = self;
        [_tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(0);
            make.height.equalTo(self.gkTabBarHeight);
        }];
    }
    return _tabBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.container.safeLayoutGuide = GKSafeLayoutGuideNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    if(self.items.count > 0){
        self.selectedIndex = 0;
    }
}

- (BOOL)isDisplaying
{
    UIViewController *vc = self.selectedViewController;
    if ([vc isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (UINavigationController*)vc;
        return nav.viewControllers.count <= 1;
    }
    
    return [super isDisplaying] && self.presentingViewController == nil;
}


// MARK: - CATabBar delegate

- (void)tabBar:(GKTabBar *)tabBar didClickAtIndex:(NSInteger)index
{
    self.selectedItemIndex = index;
}

- (BOOL)tabBar:(GKTabBar *)tabBar clickEnabledAtIndex:(NSInteger)index
{
    GKTabBarItem *item = _items[index];
    BOOL should = item.viewController != nil;
    if([self.delegate respondsToSelector:@selector(gkTabBarController:shouldSelectAtIndex:)]){
        should = [self.delegate gkTabBarController:self shouldSelectAtIndex:index];
    }
    
    return should;
}

// MARK: - property setup

- (void)setNormalColor:(UIColor *)normalColor
{
    if(![_normalColor isEqualToColor:normalColor]){
        _normalColor = normalColor;
        
        for(NSUInteger i = 0;i < self.buttons.count;i ++){
            if(i != self.tabBar.selectedIndex){
                GKTabBarButton *btn = self.buttons[i];
                btn.imageView.tintColor = self.normalColor;
                btn.textLabel.textColor = self.normalColor;
            }
        }
    }
}

- (UIColor *)normalColor
{
    if(!_normalColor){
        _normalColor = [UIColor gkColorFromHex:@"95959a"];
    }
    return _normalColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if(![_selectedColor isEqualToColor:selectedColor]){
        _selectedColor = selectedColor;
        
        if(self.tabBar.selectedIndex < self.buttons.count){
            GKTabBarButton *btn = self.buttons[self.tabBar.selectedIndex];
            btn.imageView.tintColor = self.selectedColor;
            btn.textLabel.textColor = self.selectedColor;
        }
    }
}

- (UIColor *)selectedColor
{
    if(!_selectedColor){
        _selectedColor = UIColor.gkThemeColor;
    }
    return _selectedColor;
}

- (void)setFont:(UIFont *)font
{
    if(![_font isEqual:font]){
        _font = font;
        
        for(NSUInteger i = 0;i < self.buttons.count;i ++){
            GKTabBarButton *btn = self.buttons[i];
            btn.textLabel.font = self.font;
        }
    }
}

- (UIFont *)font
{
    if(!_font){
        _font = [UIFont systemFontOfSize:12];
    }
    return _font;
}

//设置按钮 选中
- (void)setSelected:(BOOL) selected forIndex:(NSUInteger) index
{
    if(index < self.buttons.count){
        GKTabBarButton *btn = self.buttons[index];
        GKTabBarItem *item = self.items[index];
        
        if(selected){
            btn.imageView.tintColor = self.selectedColor;
            btn.textLabel.textColor = self.selectedColor;
            
            if(item.selectedImage){
                btn.imageView.image = item.selectedImage;
            }
        }else{
            btn.imageView.tintColor = self.normalColor;
            btn.textLabel.textColor = self.normalColor;
            
            btn.imageView.image = item.normalImage;
        }
    }
}

//设置选中的
- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex
{
    if(_selectedItemIndex != selectedItemIndex){
        ///以前的viewController
        UIViewController *oldViewController = [self selectedViewController];
        [self setSelected:NO forIndex:_selectedItemIndex];
        
        _selectedItemIndex = selectedItemIndex;
        UIViewController *viewController = [self selectedViewController];
        [self setSelected:YES forIndex:_selectedItemIndex];
        
        if(viewController){
            //移除以前的viewController
            if(oldViewController){
                [oldViewController.view removeFromSuperview];
                [oldViewController removeFromParentViewController];
            }
            
            if(viewController.view.superview == nil){
                [self addChildViewController:viewController];
                self.contentView = viewController.view;
                [self.view bringSubviewToFront:self.tabBar];
            }
            [viewController setNeedsStatusBarAppearanceUpdate];
        }
        
        _selectedIndex = selectedItemIndex;
        
        if([self.delegate respondsToSelector:@selector(gkTabBarController:didSelectAtIndex:)]){
            [self.delegate gkTabBarController:self didSelectAtIndex:_selectedIndex];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if(_selectedIndex != selectedIndex){
        self.tabBar.selectedIndex = selectedIndex;
        _selectedIndex = self.tabBar.selectedIndex;
    }
}

- (UIViewController*)viewControllerForIndex:(NSUInteger) index
{
    if(index < _items.count){
        GKTabBarItem *item = _items[index];
        return item.viewController;
    }
    
    return nil;
}

- (GKTabBarButton*)buttonForIndex:(NSUInteger) index
{
    return self.tabBar.buttons[index];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if(self.tabBarHidden == hidden)
        return;
    
    self.tabBarHidden = hidden;
    CGFloat height = self.tabBar.gkHeight;
    if (height == 0) {
        [self.tabBar layoutIfNeeded];
        height = self.tabBar.gkHeight;
    }
    
    void(^animations)(void) = ^{
        self.tabBar.transform = hidden ? CGAffineTransformMakeTranslation(0, height) : CGAffineTransformIdentity;
    };
    
    if(animated){
        self.tabBar.hidden = NO;
        [UIView animateWithDuration:0.25 animations:animations completion:^(BOOL finished) {
            self.tabBar.hidden = hidden;
        }];
    }else{
        animations();
        self.tabBar.hidden = hidden;
    }
}


// MARK: - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController == navigationController.viewControllers.firstObject){
        if (self.tabBar.superview != self.view) {
            [self.view addSubview:self.tabBar];
            [_tabBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(0);
            }];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController != navigationController.viewControllers.firstObject && self.tabBar.superview == self.view){
        UIView *superview = navigationController.viewControllers.firstObject.view;
        if (self.tabBar.superview != superview) {
            [superview addSubview:self.tabBar];
            [_tabBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(0);
            }];
        }
    }
}


@end

