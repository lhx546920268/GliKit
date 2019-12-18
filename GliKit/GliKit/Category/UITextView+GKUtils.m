//
//  UITextView+GKUtils.m
//  GliKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "UITextView+GKUtils.h"
#import "NSString+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIColor+GKUtils.h"
#import "UIColor+GKTheme.h"

@implementation UITextView (GKUtils)

- (void)gkAddDefaultInputAccessoryViewWithTarget:(id) target action:(SEL) action
{
    [self gkAddDefaultInputAccessoryViewWithTitle:nil target:target action:action];
}

- (void)gkAddDefaultInputAccessoryView
{
    [self gkAddDefaultInputAccessoryViewWithTarget:nil action:nil];
}

- (void)gkAddDefaultInputAccessoryViewWithTitle:(NSString *)title
{
    [self gkAddDefaultInputAccessoryViewWithTitle:title target:nil action:nil];
}

- (void)gkAddDefaultInputAccessoryViewWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    if([NSString isEmpty:title]){
        title = @"确定";
    }
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 35)];
    toolbar.backgroundColor = [UIColor gkColorFromHex:@"dbdbdb"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.gkThemeColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    if(target && action){
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn addTarget:self action:@selector(gkHandleConfirm) forControlEvents:UIControlEventTouchUpInside];
    }
    [toolbar addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(toolbar);
    }];
    
    self.inputAccessoryView = toolbar;
}

- (void)gkHandleConfirm
{
    [self resignFirstResponder];
}

@end
