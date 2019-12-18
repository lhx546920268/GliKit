//
//  RCTSinglelineTextInputView+GKReactNativeExtension.h
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import <React/RCTSinglelineTextInputView.h>
#import <React/RCTSinglelineTextInputViewManager.h>
#import <React/RCTMultilineTextInputViewManager.h>
#import <React/RCTMultilineTextInputView.h>


NS_ASSUME_NONNULL_BEGIN

@class RCTUITextView, RCTUITextField;

@interface RCTSinglelineTextInputViewManager (GKReactNativeExtension)

@end

@interface RCTSinglelineTextInputView (GKReactNativeExtension)

//通过这个标题创建 inputAccessoryView 点击的时候
@property(nonatomic, copy) NSString *inputAccessoryViewTitle;

@property(nonatomic, copy) RCTDirectEventBlock onInputAccessoryViewPress;

@property(nonatomic, readonly) RCTUITextField *backedTextInputView;

@end

@interface RCTMultilineTextInputViewManager (GKReactNativeExtension)

@end

@interface RCTMultilineTextInputView (GKReactNativeExtension)

//通过这个标题创建 inputAccessoryView 点击的时候
@property(nonatomic, copy) NSString *inputAccessoryViewTitle;

@property(nonatomic, copy) RCTDirectEventBlock onInputAccessoryViewPress;

@property(nonatomic, readonly) RCTUITextView *backedTextInputView;

@end

NS_ASSUME_NONNULL_END
