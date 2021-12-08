//
//  RCTTextField+CAExtensions.m
//  MobileRecharge
//
//  Created by 罗海雄 on 2019/11/12.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RCTTextField+CAExtensions.h"
#import <objc/runtime.h>

static char inputAccessoryViewCallbackKey;
static char inputAccessoryViewTitleKey;

@implementation RCTSinglelineTextInputViewManager(CAExtensions)

RCT_EXPORT_VIEW_PROPERTY(inputAccessoryViewTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(onInputAccessoryViewPress, RCTDirectEventBlock)

@end

@implementation RCTSinglelineTextInputView (CAExtensions)

@dynamic backedTextInputView;

- (void)setInputAccessoryViewTitle:(NSString *)inputAccessoryViewTitle
{
  UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 35)];
  toolbar.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
  
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [btn setTitle:inputAccessoryViewTitle forState:UIControlStateNormal];
  [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  btn.titleLabel.font = [UIFont systemFontOfSize:16];
  btn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
  [btn addTarget:self action:@selector(ca_handleConfirm) forControlEvents:UIControlEventTouchUpInside];
  [toolbar addSubview:btn];
  
  btn.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - 80, 0, 80, 35);
  
  self.backedTextInputView.inputAccessoryView = toolbar;
  
  objc_setAssociatedObject(self, &inputAccessoryViewTitleKey, inputAccessoryViewTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)inputAccessoryViewTitle
{
  return objc_getAssociatedObject(self, &inputAccessoryViewTitleKey);
}

- (void)setOnInputAccessoryViewPress:(RCTDirectEventBlock)onInputAccessoryViewPress
{
  objc_setAssociatedObject(self, &inputAccessoryViewCallbackKey, onInputAccessoryViewPress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTDirectEventBlock)onInputAccessoryViewPress
{
  return objc_getAssociatedObject(self, &inputAccessoryViewCallbackKey);
}

- (void)ca_handleConfirm
{
  RCTDirectEventBlock callback = self.onInputAccessoryViewPress;
  if(callback){
    callback(nil);
  }else{
    [self.backedTextInputView resignFirstResponder];
  }
}

@end
