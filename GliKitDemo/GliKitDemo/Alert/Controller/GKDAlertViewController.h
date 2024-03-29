//
//  GKDAlertViewController.h
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/12/10.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDTextContainer : UIView

@end

@interface GKDAlertViewController : GKBaseViewController

@property (weak, nonatomic) IBOutlet GKButton *alertButton;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet GKButton *titleButton;
@property (weak, nonatomic) IBOutlet GKButton *imageButton;
@end

NS_ASSUME_NONNULL_END
