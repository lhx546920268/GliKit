//
//  GKPopoverMenu.m
//  GliKit
//
//  Created by 罗海雄 on 2019/9/30.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKPopoverMenu.h"
#import "UIColor+GKUtils.h"
#import "NSString+GKUtils.h"
#import "GKBaseDefines.h"
#import "UIButton+GKUtils.h"
#import "UIFont+GKUtils.h"
#import "UIColor+GKTheme.h"
#import "GKDivider.h"
#import "UIScreen+GKUtils.h"
#import "UIView+GKAutoLayout.h"

@implementation GKPopoverMenuItem

+ (id)infoWithTitle:(NSString*) title icon:(UIImage*) icon
{
    GKPopoverMenuItem *item = [GKPopoverMenuItem new];
    item.title = title;
    item.icon = icon;
    
    return item;
}

@end

@implementation GKPopoverMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.selectedBackgroundView = [[UIView alloc] init];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _button.adjustsImageWhenDisabled = NO;
        _button.adjustsImageWhenHighlighted = NO;
        _button.enabled = NO;
        _button.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_button];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(0);
        }];
        
        _divider = [GKDivider new];
        [self.contentView addSubview:_divider];
        [_divider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.equalTo(0);
        }];
    }
    
    return self;
}


@end

@interface GKPopoverMenu()<UITableViewDelegate, UITableViewDataSource>

/**
 按钮列表
 */
@property(nonatomic, strong) UITableView *tableView;

@end

@implementation GKPopoverMenu

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.contentInsets = UIEdgeInsetsZero;
        _cellContentInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        _textColor = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:13];
        _selectedBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _rowHeight = 30;
        _separatorColor = UIColor.gkSeparatorColor;
        _iconTitleInterval = 0.0;
    }
    
    return self;
}

- (void)initContentView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = _rowHeight;
        _tableView.separatorColor = _separatorColor;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        self.contentView = _tableView;
    }
    _tableView.frame = CGRectMake(0, 0, [self getMenuWidth], _menuItems.count * _rowHeight);
}

- (void)reloadData
{
    if(self.tableView){
        _tableView.frame = CGRectMake(0, 0, [self getMenuWidth], _menuItems.count * _rowHeight);
        [self.tableView reloadData];
        [self redraw];
    }
}

///通过标题获取菜单宽度
- (CGFloat)getMenuWidth
{
    if(_menuWidth == 0){
        CGFloat contentWidth = 0;
        for(GKPopoverMenuItem *item in self.menuItems){
            CGSize size = [item.title gkStringSizeWithFont:_font contraintWith:UIScreen.gkScreenWidth];
            size.width += 1.0;
            contentWidth = MAX(contentWidth, size.width + item.icon.size.width + _iconTitleInterval);
        }
        
        return contentWidth + _cellContentInsets.left + _cellContentInsets.right;
    }else{
        return _menuWidth;
    }
}

// MARK: - Property

- (void)setTextColor:(UIColor *)textColor
{
    if(![_textColor isEqualToColor:textColor]){
        if(!textColor)
            textColor = [UIColor blackColor];
        _textColor = textColor;
        [self.tableView reloadData];
    }
}

- (void)setFont:(UIFont *)font
{
    if(![_font isEqualToFont:font]){
        if(!font)
            font = [UIFont systemFontOfSize:13];
        _font = font;
        [self.tableView reloadData];
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    if(![_selectedBackgroundColor isEqualToColor:selectedBackgroundColor]){
        if(!selectedBackgroundColor)
            selectedBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _selectedBackgroundColor = selectedBackgroundColor;
        [self.tableView reloadData];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if(![_separatorColor isEqualToColor:separatorColor]){
        if(!separatorColor)
            separatorColor = UIColor.gkSeparatorColor;
        _separatorColor = separatorColor;
        [self.tableView reloadData];
    }
}

- (void)setSeparatorInsets:(UIEdgeInsets)separatorInsets
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_separatorInsets, separatorInsets)){
        _separatorInsets = separatorInsets;
        [self.tableView reloadData];
    }
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if(_rowHeight != rowHeight){
        _rowHeight = rowHeight;
        [self reloadData];
    }
}

- (void)setMenuWidth:(CGFloat)menuWidth
{
    if(_menuWidth != menuWidth){
        _menuWidth = menuWidth;
        [self reloadData];
    }
}

- (void)setIconTitleInterval:(CGFloat)iconTitleInterval
{
    if(_iconTitleInterval != iconTitleInterval){
        _iconTitleInterval = iconTitleInterval;
        [self reloadData];
    }
}

- (void)setCellContentInsets:(UIEdgeInsets)cellContentInsets
{
    if(!UIEdgeInsetsEqualToEdgeInsets(_cellContentInsets, cellContentInsets)){
        _cellContentInsets = cellContentInsets;
        [self reloadData];
    }
}

- (void)setMenuItems:(NSArray<GKPopoverMenuItem *> *)menuItems
{
    if(_menuItems != menuItems){
        _menuItems = menuItems;
        [self reloadData];
    }
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    if(titles.count == 0){
        return;
    }
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:titles.count];
    for(NSString *title in titles){
        [items addObject:[GKPopoverMenuItem infoWithTitle:title icon:nil]];
    }
    self.menuItems = items;
}

- (NSArray<NSString*>*)titles
{
    if(_menuItems.count == 0){
        return nil;
    }
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:_menuItems.count];
    for(GKPopoverMenuItem *item in _menuItems){
        if(item.title == nil){
            [titles addObject:@""];
        }else{
            [titles addObject:item.title];
        }
    }
    return titles;
}

#pragma mark- UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    GKPopoverMenuCell *cell = [[GKPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[GKPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectedBackgroundView.backgroundColor = _selectedBackgroundColor;
    cell.button.titleLabel.font = _font;
    [cell.button setTitleColor:_textColor forState:UIControlStateNormal];
    cell.button.tintColor = _textColor;
    cell.button.gkLeftLayoutConstraint.constant = _cellContentInsets.left;
    cell.button.gkRightLayoutConstraint.constant = _cellContentInsets.right;
    
    GKPopoverMenuItem *item = [_menuItems objectAtIndex:indexPath.row];
    [cell.button setTitle:item.title forState:UIControlStateNormal];
    [cell.button setImage:item.icon forState:UIControlStateNormal];
    
    cell.divider.hidden = indexPath.row == _menuItems.count - 1;
    cell.divider.backgroundColor = _separatorColor;
    cell.divider.gkLeftLayoutConstraint.constant = _separatorInsets.left;
    cell.divider.gkRightLayoutConstraint.constant = _separatorInsets.right;
    
    [cell.button gkSetImagePosition:GKButtonImagePositionLeft margin:_iconTitleInterval];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    if([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.delegate respondsToSelector:@selector(popoverMenu:didSelectAtIndex:)]){
        [self.delegate popoverMenu:self didSelectAtIndex:indexPath.row];
    }
    !self.selectHandler ?: self.selectHandler(indexPath.row);
    [self dismissAnimated:YES];
}

@end
