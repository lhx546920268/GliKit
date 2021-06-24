//
//  GKIndexSearchBar.m
//  GliKit
//
//  Created by 罗海雄 on 2021/6/21.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

#import "GKIndexSearchBar.h"
#import "NSString+GKUtils.h"

@interface GKIndexSearchBar ()

///标签
@property(nonatomic, strong) NSMutableArray<UILabel*> *items;

///内容大小
@property(nonatomic, assign) CGSize contentSize;

///每个大小
@property(nonatomic, assign) CGFloat sizePerItem;

///间隔
@property(nonatomic, assign) CGFloat spacing;

@end

@implementation GKIndexSearchBar

- (NSMutableArray<UILabel *> *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesDidChange:touches.anyObject];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesDidChange:touches.anyObject];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesDidChange:touches.anyObject];
    NSLog(@"touchesEnded");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesDidChange:touches.anyObject];
    NSLog(@"touchesCancelled");
}

- (void)touchesDidChange:(UITouch*) touch
{
    if (_indexTitles.count > 0) {
        CGFloat y = [touch locationInView:self].y;
        
        NSInteger index = y / self.sizePerItem;
        if (index < 0) {
            index = 0;
        } else if (index >= _indexTitles.count) {
            index = _indexTitles.count - 1;
        }
        if (self.selectedIndex != index) {
            self.selectedIndex = index;
            !self.indexDidChange ?: self.indexDidChange(index, _indexTitles[index]);
        }
    }
}

- (void)setIndexTitles:(NSArray<NSString *> *)indexTitles
{
    if (_indexTitles != indexTitles) {
        _indexTitles = [indexTitles copy];
        
        self.selectedIndex = 0;
        self.backgroundColor = UIColor.redColor;
        for (UIView *item in self.items) {
            [item removeFromSuperview];
        }
        
        self.spacing = 8;
        UIFont *font = [UIFont systemFontOfSize:13];
        CGFloat size = MAX([_indexTitles.firstObject gkStringSizeWithFont:font].width, font.lineHeight);
        
        CGFloat y = 0;
        
        for (NSString *title in _indexTitles) {
            UILabel *item = [UILabel new];
            item.font = font;
            item.textColor = UIColor.systemBlueColor;
            item.textAlignment = NSTextAlignmentCenter;
            item.text = title;
            [self addSubview:item];
            
            item.frame = CGRectMake(0, y, size, size);
            y += self.spacing + size;
            [self.items addObject:item];
        }
        if (y > 0) {
            y -= self.spacing;
        }
        self.contentSize = CGSizeMake(size, y);
        self.sizePerItem = size;
        
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    return self.contentSize;
}

@end
