//
//  RCTTextField+CAExtensions.h
//  MobileRecharge
//
//  Created by 罗海雄 on 2019/11/12.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTSinglelineTextInputView.h>
#import <React/RCTSinglelineTextInputViewManager.h>
#import <React/RCTUITextField.h>

NS_ASSUME_NONNULL_BEGIN


@interface RCTSinglelineTextInputViewManager (CAExtensions)

@end

@interface RCTSinglelineTextInputView (CAExtensions)

//通过这个标题创建 inputAccessoryView 点击的时候
@property(nonatomic, copy) NSString *inputAccessoryViewTitle;

@property(nonatomic, copy) RCTDirectEventBlock onInputAccessoryViewPress;

@property(nonatomic, readonly) RCTUITextField *backedTextInputView;

@end

NS_ASSUME_NONNULL_END
