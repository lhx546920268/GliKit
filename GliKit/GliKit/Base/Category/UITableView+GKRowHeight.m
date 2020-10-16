//
//  UITableView+GKRowHeight.m
//  GliKit
//
//  Created by 罗海雄 on 2019/3/22.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "UITableView+GKRowHeight.h"
#import <objc/runtime.h>
#import "UIView+GKAutoLayout.h"
#import "NSObject+GKUtils.h"

@implementation UITableView (GKRowHeight)

+ (void)load {
    SEL selectors[] = {
        
        @selector(registerNib:forCellReuseIdentifier:),
        @selector(registerClass:forCellReuseIdentifier:),
        @selector(registerNib:forHeaderFooterViewReuseIdentifier:),
        @selector(registerClass:forHeaderFooterViewReuseIdentifier:),
    };
    
    for(NSInteger i = 0;i < sizeof(selectors) / sizeof(SEL);i ++){
        
        [self gkExchangeImplementations:selectors[i] prefix:@"gkRowHeight_"];
    }
}

// MARK: - register cells

- (void)gkRowHeight_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self gkRowHeight_registerNib:nib forCellReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:nib forKey:identifier];
}

- (void)gkRowHeight_registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    [self gkRowHeight_registerClass:cellClass forCellReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:NSStringFromClass(cellClass) forKey:identifier];
}

- (void)gkRowHeight_registerNib:(UINib *)nib forHeaderFooterViewReuseIdentifier:(NSString *)identifier
{
    [self gkRowHeight_registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:nib forKey:identifier];
}

- (void)gkRowHeight_registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier
{
    [self gkRowHeight_registerClass:aClass forHeaderFooterViewReuseIdentifier:identifier];
    [[self gkRegisterObjects] setObject:NSStringFromClass(aClass) forKey:identifier];
}

// MARK: - 计算

- (CGFloat)gkRowHeightForIdentifier:(NSString *)identifier model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        //计算大小
        UITableViewCell<GKTableConfigurableItem> *cell = [self gkCellForIdentifier:identifier];
        if(!cell){
            //有时候cell没有注册，而是直接创建的
            cell = [self dequeueReusableCellWithIdentifier:identifier];
        }
        return [self gkRowHeightForCell:cell model:model];
    }
    
    return model.rowHeight;
}

- (CGFloat)gkRowHeightForCell:(UITableViewCell<GKTableConfigurableItem>*)cell model:(id<GKRowHeightModel>)model
{
    NSAssert([cell conformsToProtocol:@protocol(GKTableConfigurableItem)], @"%@ must confirms protocol %@", NSStringFromClass(cell.class), NSStringFromProtocol(@protocol(GKTableConfigurableItem)));
    if(model.rowHeight == 0){
        CGFloat width = CGRectGetWidth(self.frame);
        
        //当使用系统的accessoryView时，content宽度会向右偏移
        if(cell.accessoryView){
            width -= 16.0 + CGRectGetWidth(cell.accessoryView.frame);
        }else{
            switch (cell.accessoryType){
                case UITableViewCellAccessoryDisclosureIndicator :
                    //箭头
                    width -= 34.0;
                    break;
                case UITableViewCellAccessoryCheckmark :
                    //勾
                    width -= 40.0;
                    break;
                case UITableViewCellAccessoryDetailButton :
                    //详情
                    width -= 48.0;
                    break;
                case UITableViewCellAccessoryDetailDisclosureButton :
                    //箭头+详情
                    width -= 68.0;
                    break;
                default:
                    break;
            }
        }
        
        cell.model = model;
        CGFloat height = [cell.contentView gkSizeThatFits:CGSizeMake(width, 0) type:GKAutoLayoutCalcTypeHeight].height;
        
        //如果有分割线 加上1px
        if(self.separatorStyle != UITableViewCellSeparatorStyleNone){
            height += 1.0 / [UIScreen mainScreen].scale;
        }
        model.rowHeight = height;
    }
    
    return model.rowHeight;
}

- (CGFloat)gkHeaderFooterHeightForIdentifier:(NSString *)identifier model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        //计算大小
        UIView<GKTableConfigurableItem>* view = [self gkCellForIdentifier:identifier];
        if(!view){
            //有时候cell没有注册，而是直接创建的
            view = (UIView<GKTableConfigurableItem>*)[self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        }
        model.rowHeight = [self gkHeightForHeaderFooter:view model:model];
    }
    
    return model.rowHeight;
}

- (CGFloat)gkHeightForHeaderFooter:(UIView<GKTableConfigurableItem>*)headerFooter model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        NSAssert([headerFooter conformsToProtocol:@protocol(GKTableConfigurableItem)], @"%@ must confirms protocol %@", NSStringFromClass(headerFooter.class), NSStringFromProtocol(@protocol(GKTableConfigurableItem)));
        headerFooter.model = model;
        model.rowHeight = [headerFooter gkSizeThatFits:CGSizeMake(self.frame.size.width, 0) type:GKAutoLayoutCalcTypeHeight].height;
    }
    return model.rowHeight;
}

// MARK: - 注册的 cells

///注册的 class nib
- (NSMutableDictionary*)gkRegisterObjects
{
    NSMutableDictionary *objects = objc_getAssociatedObject(self, _cmd);
    if (objects == nil){
        objects = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, objects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objects;
}

///注册的cells header footer 用来计算
- (__kindof UIView*)gkCellForIdentifier:(NSString *)identifier
{
    /**
     不用 dequeueReusableCellWithIdentifier 是因为会创建N个cell
     */
    
    NSMutableDictionary<NSString*, UIView*> *cells = objc_getAssociatedObject(self, _cmd);
    if (cells == nil){
        cells = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UIView *view = [cells objectForKey:identifier];
    if(view == nil){
        NSObject *obj = [[self gkRegisterObjects] objectForKey:identifier];
        if([obj isKindOfClass:[UINib class]]){
            UINib *nib = (UINib*)obj;
            view = [[nib instantiateWithOwner:nil options:nil] firstObject];
            [cells setObject:view forKey:identifier];
        }else if([obj isKindOfClass:[NSString class]]){
            Class clazz = NSClassFromString((NSString*)obj);
            view = [clazz new];
            [cells setObject:view forKey:identifier];
        }
    }
    
    return view;
}


@end
