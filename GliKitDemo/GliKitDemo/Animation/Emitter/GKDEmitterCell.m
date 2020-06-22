//
//  GKDEmitterCell.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/6/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDEmitterCell.h"

@implementation GKDEmitterCell

- (void)refreshWithHeight:(CGFloat)height
{
    self.currentFrame ++;
    
    int frame = self.currentFrame / self.duration;
    
    if(frame > 60){
        self.currentFrame = 0;
    }
    self.y = frame / 60.0 * height;
}

@end
