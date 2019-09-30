//
//  GKMenuBarProps.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/15.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKMenuBarProps.h"
#import "UIColor+GKTheme.h"

@implementation GKMenuBarProps

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemPadding = 10.0;
        self.itemInterval = 5.0;
        self.indicatorHeight = 2.0;
        self.displayItemDidvider = YES;
    }
    return self;
}

- (UIColor *)normalTextColor
{
    if(!_normalTextColor){
        return [UIColor darkGrayColor];
    }
    return _normalTextColor;
}

- (UIFont *)normalFont
{
    if(!_normalFont){
        return [UIFont systemFontOfSize:13];
    }
    
    return _normalFont;
}

- (UIColor *)selectedTextColor
{
    if(!_selectedTextColor){
        return UIColor.gkThemeColor;
    }
    return _selectedTextColor;
}

- (UIFont *)selectedFont
{
    if(!_selectedFont){
        return self.normalFont;
    }
    return _selectedFont;
}

- (UIColor *)indicatorColor
{
    if(!_indicatorColor){
        return self.selectedTextColor;
    }
    return _indicatorColor;
}

@end
