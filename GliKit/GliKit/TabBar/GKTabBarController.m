//
//  GKTabBarController.m
//  GliKit
//
//  Created by luohaixiong on 2020/2/28.
//  Copyright © 2020 GliKit. All rights reserved.
//

#import "GKTabBarController.h"
#import "GKTabBar.h"
#import "GKTabBarItem.h"
#import "GKContainer.h"
#import "UIColor+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "UIView+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIViewController+GKUtils.h"

@implementation GKTabBarItemInfo

+ (instancetype)infoWithTitle:(NSString*) title normalImage:(UIImage*) normalImage viewController:(UIViewController *)viewControllr
{
    return [self infoWithTitle:title normalImage:normalImage selectedImage:nil viewController:viewControllr];
}

+ (instancetype)infoWithTitle:(NSString*) title normalImage:(UIImage*) normalImage selectedImage:(UIImage*) selectedImage viewController:(UIViewController*) viewControllr
{
    GKTabBarItemInfo *info = [[GKTabBarItemInfo alloc] init];
    info.title = title;
    if(!selectedImage){
        ///ios7 的 imageAssets 不支持 Template
        if(normalImage.renderingMode != UIImageRenderingModeAlwaysTemplate){
            normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    info.normalImage = normalImage;
    info.selectedImage = selectedImage;
    info.viewController = viewControllr;
    
    return info;
}

@end

@interface GKTabBarController ()<GKTabBarDelegate>

/**
 选中的视图
 */
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

- (void)setItemInfos:(NSArray<GKTabBarItemInfo *> *)itemInfos
{
    if(_itemInfos != itemInfos){
        _itemInfos = [itemInfos copy];
        
        //创建选项卡按钮
        NSMutableArray *tabbarItems = [NSMutableArray arrayWithCapacity:itemInfos.count];
        
        for(NSInteger i = 0;i < itemInfos.count;i ++){
            
            //创建选项卡按钮
            GKTabBarItemInfo *info = itemInfos[i];

            GKTabBarItem *item = [GKTabBarItem new];
            item.textLabel.textColor = self.normalColor;
            item.textLabel.font = self.font;
            item.textLabel.text = info.title;
            item.imageView.image = info.normalImage;
            [tabbarItems addObject:item];
            
            info.viewController.gkHasTabBar = YES;
        }
        _tabBarItems = [tabbarItems copy];
        _tabBar.items = _tabBarItems;
        
        
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
    if(_selectedItemIndex < _itemInfos.count){
        GKTabBarItemInfo *info = _itemInfos[_selectedItemIndex];
        return info.viewController;
    }
    
    return nil;
}

// MARK: - 加载视图

- (GKTabBar*)tabBar
{
    if(!_tabBar){
        _tabBar = [[GKTabBar alloc] initWithItems:self.tabBarItems];
        _tabBar.delegate = self;
        [_tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
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
    if(self.itemInfos.count > 0){
        self.selectedIndex = 0;
    }
}

// MARK: - CATabBar delegate

- (void)tabBar:(GKTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index
{
    self.selectedItemIndex = index;
}

- (BOOL)tabBar:(GKTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index
{
    GKTabBarItemInfo *info = _itemInfos[index];
    BOOL should = info.viewController != nil;
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
        
        for(NSUInteger i = 0;i < self.tabBarItems.count;i ++){
            if(i != self.tabBar.selectedIndex){
                GKTabBarItem *item = self.tabBarItems[i];
                item.imageView.tintColor = self.normalColor;
                item.textLabel.textColor = self.normalColor;
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
        
        if(self.tabBar.selectedIndex < self.tabBarItems.count){
            GKTabBarItem *item = self.tabBarItems[self.tabBar.selectedIndex];
            item.imageView.tintColor = self.selectedColor;
            item.textLabel.textColor = self.selectedColor;
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
        
        for(NSUInteger i = 0;i < self.tabBarItems.count;i ++){
            GKTabBarItem *item = self.tabBarItems[i];
            item.textLabel.font = self.font;
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

//设置item 选中
- (void)setSelected:(BOOL) selected forIndex:(NSUInteger) index
{
    if(index < self.tabBarItems.count){
        GKTabBarItem *item = self.tabBarItems[index];
        GKTabBarItemInfo *info = self.itemInfos[index];
        
        if(selected){
            item.imageView.tintColor = self.selectedColor;
            item.textLabel.textColor = self.selectedColor;
            
            if(info.selectedImage){
                item.imageView.image = info.selectedImage;
            }
        }else{
            item.imageView.tintColor = self.normalColor;
            item.textLabel.textColor = self.normalColor;
            
            item.imageView.image = info.normalImage;
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
                
                [self.tabBar removeFromSuperview];
                if([viewController isKindOfClass:UINavigationController.class]){
                    UINavigationController *nav = (UINavigationController*)viewController;
                    viewController = nav.viewControllers.firstObject;
                }
                
                [viewController.view addSubview:self.tabBar];
                [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.bottom.equalTo(0);
                }];
            }
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
    if(index < _itemInfos.count){
        GKTabBarItemInfo *info = _itemInfos[index];
        return info.viewController;
    }
    
    return nil;
}

- (GKTabBarItem*)itemForIndex:(NSUInteger) index
{
    return self.tabBar.items[index];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if(self.tabBarHidden == hidden)
        return;
    
    self.tabBarHidden = hidden;
    if(animated){
        self.tabBar.hidden = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
           
            self.tabBar.transform = hidden ? CGAffineTransformMakeTranslation(0, self.tabBar.gkHeight) : CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            self.tabBar.hidden = hidden;
        }];
    }else{
        self.tabBar.hidden = hidden;
    }
}

@end

