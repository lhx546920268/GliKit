//
//  GKTextField.h
//  GliKit
//
//  Created by 罗海雄 on 2019/5/21.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///输入框
@interface GKTextField : UITextField

///禁止的方法列表，如复制，粘贴，通过 NSStringFromSelector 把需要禁止的方法传进来，如禁止粘贴，可传 NSStringFromSelector(paste:) default `nil`
@property(nonatomic, strong, nullable) NSArray<NSString*> *forbiddenActions;

///内容间距 default `zero`
@property(nonatomic, assign) IBInspectable UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
