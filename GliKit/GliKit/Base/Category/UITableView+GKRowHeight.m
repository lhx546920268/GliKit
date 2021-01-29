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
#import "GKRowHeightModel.h"

@implementation UITableView (GKRowHeight)

// MARK: - 计算

- (CGFloat)gkRowHeightForIdentifier:(NSString *)identifier model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        //计算大小
        UITableViewCell<GKTableConfigurableItem> *cell = [self gkCellForIdentifier:identifier isHeaderFooter:NO];
        return [self gkRowHeightForCell:cell model:model];
    }
    
    return model.rowHeight;
}

- (CGFloat)gkRowHeightForCell:(UITableViewCell<GKTableConfigurableItem>*)cell model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        CGFloat width = CGRectGetWidth(self.frame);
        if(width == 0){
            //设置 UITableView的某些属性会触发 获取高度代理，比如layoutMargins，tableHeaderView, 这时如果还没设置frame，直接返回0
            return 0;
        }
        
        NSAssert([cell respondsToSelector:@selector(setModel:)], @"cell for identifier %@ must imple setModel: ", NSStringFromClass(cell.class));
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
        UIView<GKTableConfigurableItem>* view = [self gkCellForIdentifier:identifier isHeaderFooter:YES];
        model.rowHeight = [self gkHeightForHeaderFooter:view model:model];
    }
    
    return model.rowHeight;
}

- (CGFloat)gkHeightForHeaderFooter:(UIView<GKTableConfigurableItem>*)headerFooter model:(id<GKRowHeightModel>)model
{
    if(model.rowHeight == 0){
        CGFloat width = CGRectGetWidth(self.frame);
        if(width == 0){
            //设置 UITableView的某些属性会触发 获取高度代理，比如layoutMargins，tableHeaderView, 这时如果还没设置frame，直接返回0
            return 0;
        }
        NSAssert([headerFooter respondsToSelector:@selector(setModel:)], @"cell for identifier %@ must imple setModel: ", NSStringFromClass(headerFooter.class));
        headerFooter.model = model;
        UIView *contentView = headerFooter;
        if([headerFooter isKindOfClass:UITableViewHeaderFooterView.class]){
            contentView = [(UITableViewHeaderFooterView*)headerFooter contentView];
        }
        model.rowHeight = [headerFooter gkSizeThatFits:CGSizeMake(self.frame.size.width, 0) type:GKAutoLayoutCalcTypeHeight].height;
    }
    return model.rowHeight;
}

// MARK: - 注册的 cells

///注册的cells header footer 用来计算
- (__kindof UIView*)gkCellForIdentifier:(NSString *)identifier isHeaderFooter:(BOOL) isHeaderFooter
{
    NSMutableDictionary<NSString*, UIView*> *cells = objc_getAssociatedObject(self, _cmd);
    if (cells == nil){
        cells = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UIView *view = cells[identifier];
    if(view == nil){
        if(isHeaderFooter){
            view = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        }else{
            view = [self dequeueReusableCellWithIdentifier:identifier];
        }
        cells[identifier] = view;
    }
    
    return view;
}


@end
