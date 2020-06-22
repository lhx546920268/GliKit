//
//  GKDEmitterView.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2020/6/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

#import "GKDEmitterView.h"
#import <GKWeakProxy.h>
#import "GKDEmitterCell.h"

@interface GKDEmitterView ()

///
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) NSArray<GKDEmitterCell*> *cells;

///xx
@property(nonatomic, assign) NSInteger count;

@end

@implementation GKDEmitterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        NSInteger count = 100;
        NSMutableArray *cells = [NSMutableArray arrayWithCapacity:count];
        for(NSInteger i = 0;i < count;i ++){
            GKDEmitterCell *cell = [GKDEmitterCell new];
            cell.duration = random() % 250 / 100.0;
            cell.x = random() % 320;
            [cells addObject:cell];
        }
        self.cells = cells;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
    
    for(GKDEmitterCell *cell in self.cells){
        CGContextAddArc(context, cell.x, cell.y, 20, 0, M_PI * 2, 0);
        CGContextDrawPath(context, kCGPathFill);
    }
    
    CGContextRestoreGState(context);
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(newWindow){
        if(!self.displayLink){
            self.displayLink = [CADisplayLink displayLinkWithTarget:[GKWeakProxy weakProxyWithTarget:self] selector:@selector(handleDisplayLink:)];
        }
        [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }else{
        [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}

- (void)handleDisplayLink:(CADisplayLink*) displayLink
{
    if(self.count == 0){
        for(GKDEmitterCell *cell in self.cells){
            [cell refreshWithHeight:self.gkHeight];
        }
        [self setNeedsDisplay];
    }
//    self.count ++;
//    if(self.count >= 3){
//        self.count = 0;
//    }
}


@end
