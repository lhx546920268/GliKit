//
//  GKPhotosViewController.h
//  IOSLibrary
//
//  Created by 罗海雄 on 2019/7/1.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKTableViewController.h"
#import "GKPhotosOptions.h"

///相册
@interface GKPhotosViewController : GKTableViewController

///选项
@property(nonatomic, readonly) GKPhotosOptions *photosOptions;

@end

