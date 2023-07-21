//
//  GKDTableEmptyViewController.m
//  GliKitDemo
//
//  Created by 罗海雄 on 2019/9/25.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKDTableEmptyViewController.h"
#import <GKRowHeightModel.h>

@interface GKDTableEmptyModel : NSObject<GKRowHeightModel>

///
@property(nonatomic, copy) NSString *title;

@end

@implementation GKDTableEmptyModel

@synthesize rowHeight;

@end

@interface GKDTableEmptyCell : UITableViewCell

@property(nonatomic, readonly) UILabel *titleLabel;

@property(nonatomic, strong) GKDTableEmptyModel *model;

@end

@implementation GKDTableEmptyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [UILabel new];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@25);
            make.top.equalTo(@15);
            make.bottom.mas_equalTo(-15);
        }];
    
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)setModel:(GKDTableEmptyModel *)model
{
    _model = model;
    _titleLabel.text = _model.title;
}

@end

@interface GKDTableEmptyViewController ()

@property(nonatomic, assign) NSInteger count;
///
@property(nonatomic, strong) NSArray<GKDTableEmptyModel*> *models;

@end

@implementation GKDTableEmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.count = 10;
    NSMutableArray *models = [NSMutableArray array];
    
    self.view.backgroundColor = UIColor.gkGrayBackgroundColor;
    for(NSInteger i = 0;i < self.count;i ++){
        GKDTableEmptyModel *model = GKDTableEmptyModel.new;
        
        model.title = [NSString stringWithFormat:@"%d", rand()];
        [models addObject:model];
    }
    self.models = models;
    [self registerClass:GKDTableEmptyCell.class];
    [self initViews];
    
    self.tableView.gkShouldShowEmptyView = YES;
}

- (void)emptyViewWillAppear:(GKEmptyView *)view
{
    [super emptyViewWillAppear:view];
    if(view.gestureRecognizers.count == 0){
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEmpty)]];
    }
}

- (void)handleTapEmpty
{
    self.count = 10;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView gkRowHeightForIdentifier:GKDTableEmptyCell.gkNameOfClass model:self.models[indexPath.item]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKDTableEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:GKDTableEmptyCell.gkNameOfClass forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.count = 0;
    [tableView reloadData];
}

@end
