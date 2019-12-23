//
//  RCTSinglelineTextInputView+GKReactNativeExtension.m
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaisxiong. All rights reserved.
//

#import "RCTSinglelineTextInputView+GKReactNativeExtension.h"
#import <objc/runtime.h>
#import <UITextField+GKUtils.h>
#import <React/RCTUITextField.h>
#import <React/RCTUITextView.h>
#import <UITextView+GKUtils.h>

static char GKOnInputAccessoryViewCallbackKey;
static char GKInputAccessoryViewTitleKey;

@implementation RCTSinglelineTextInputViewManager(GKReactNativeExtension)

RCT_EXPORT_VIEW_PROPERTY(inputAccessoryViewTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(onInputAccessoryViewPress, RCTDirectEventBlock)

@end

@implementation RCTSinglelineTextInputView (GKReactNativeExtension)

@dynamic backedTextInputView;

- (void)setInputAccessoryViewTitle:(NSString *)inputAccessoryViewTitle
{
    if([NSString isEmpty:inputAccessoryViewTitle]){
        self.backedTextInputView.inputAccessoryView = nil;
    }else{
        [self.backedTextInputView gkAddDefaultInputAccessoryViewWithTitle:inputAccessoryViewTitle target:self action:@selector(gkHandleInputAccessoryConfirm)];
    }
  objc_setAssociatedObject(self, &GKInputAccessoryViewTitleKey, inputAccessoryViewTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)inputAccessoryViewTitle
{
  return objc_getAssociatedObject(self, &GKInputAccessoryViewTitleKey);
}

- (void)setOnInputAccessoryViewPress:(RCTDirectEventBlock)onInputAccessoryViewPress
{
  objc_setAssociatedObject(self, &GKOnInputAccessoryViewCallbackKey, onInputAccessoryViewPress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTDirectEventBlock)onInputAccessoryViewPress
{
  return objc_getAssociatedObject(self, &GKOnInputAccessoryViewCallbackKey);
}

- (void)gkHandleInputAccessoryConfirm
{
  RCTDirectEventBlock callback = self.onInputAccessoryViewPress;
  if(callback){
    callback(nil);
  }else{
    [self.backedTextInputView resignFirstResponder];
  }
}

@end

@implementation RCTMultilineTextInputViewManager(GKReactNativeExtension)

RCT_EXPORT_VIEW_PROPERTY(inputAccessoryViewTitle, NSString)
RCT_EXPORT_VIEW_PROPERTY(onInputAccessoryViewPress, RCTDirectEventBlock)

@end

@implementation RCTMultilineTextInputView (GKReactNativeExtension)

@dynamic backedTextInputView;

- (void)setInputAccessoryViewTitle:(NSString *)inputAccessoryViewTitle
{
    if([NSString isEmpty:inputAccessoryViewTitle]){
        self.backedTextInputView.inputAccessoryView = nil;
    }else{
        [self.backedTextInputView gkAddDefaultInputAccessoryViewWithTitle:inputAccessoryViewTitle target:self action:@selector(gkHandleInputAccessoryConfirm)];
    }
  objc_setAssociatedObject(self, &GKInputAccessoryViewTitleKey, inputAccessoryViewTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)inputAccessoryViewTitle
{
  return objc_getAssociatedObject(self, &GKInputAccessoryViewTitleKey);
}

- (void)setOnInputAccessoryViewPress:(RCTDirectEventBlock)onInputAccessoryViewPress
{
  objc_setAssociatedObject(self, &GKOnInputAccessoryViewCallbackKey, onInputAccessoryViewPress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RCTDirectEventBlock)onInputAccessoryViewPress
{
  return objc_getAssociatedObject(self, &GKOnInputAccessoryViewCallbackKey);
}

- (void)gkHandleInputAccessoryConfirm
{
  RCTDirectEventBlock callback = self.onInputAccessoryViewPress;
  if(callback){
    callback(nil);
  }else{
    [self.backedTextInputView resignFirstResponder];
  }
}

@end
