//
//  NLDropDownMenu.m
//  NLDropDownMenuDemo
//
//  Created by Neil-Lee on 15/5/13.
//  Copyright (c) 2015年 Neil-Lee. All rights reserved.
//


#import "NLDropDownMenu.h"
#import "DropDownMenuCell.h"
@implementation NLIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}


+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row {
    NLIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}


@end

#pragma mark - menu implementation

@interface NLDropDownMenu (){
    //标记方法是否实现的旗帜
    struct {
        unsigned int numberOfRowsInColumn :1;
        unsigned int titleForRowAtIndexPath :1;
    }_dataSourceFlags;
}

@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;  // 当前选中列
@property (nonatomic, assign) NSInteger currentSelectedMenudRow;    // 当前选中行
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITableView *tableView;

//layers array
@property (nonatomic, strong) NSMutableArray *titles;

@end

#define kTableViewCellHeight 43
#define kTableViewHeight 258
#define kTextFontSize 14
#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kCellBgColor [UIColor whiteColor];
#define kTextSelectColor [UIColor colorWithRed:76/255.0 green:195/255.0 blue:255/255.0 alpha:1]
#define kSeparatorColor [UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1]
@class NLTapLabel;
@implementation NLDropDownMenu

- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat menuX = origin.x;
    CGFloat menuY = origin.y;
    CGFloat menuW = screenSize.width;
    CGFloat menuH = height;
    
    if (self = [super initWithFrame:CGRectMake(menuX, menuY, menuW, menuH)]) {
        self.backgroundColor = kSeparatorColor;
        
        _show = NO;
        self.currentSelectedMenudIndex = -1;
        self.titles = [NSMutableArray array];
        self.textColor = kTextColor;
        self.textSelectedColor = kTextSelectColor;
        self.fontSize = kTextFontSize;
        self.cellBgColor = kCellBgColor;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(menuX, menuY + menuH, menuW, 0) style:UITableViewStylePlain];
        _tableView.rowHeight = kTableViewCellHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        
        
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(menuX, menuY, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
    }
    return self;
}




- (NSString *)titleForRowAtIndexPath:(NLIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

#pragma mark 设置默认选择项
- (void)selectDefalutIndexPath:(NLIndexPath *)indexPath
{
    if (indexPath == nil) {
        indexPath = [NLIndexPath indexPathWithCol:0 row:0];
    }
    if (_dataSource && _delegate
        && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        
        if (_dataSourceFlags.numberOfRowsInColumn
            && [_dataSource menu:self numberOfRowsInColumn:0] > 0){
            [_delegate menu:self didSelectRowAtIndexPath:[NLIndexPath indexPathWithCol:indexPath.column row:indexPath.row
                                                          ]];
        }
    }
}

#pragma mark - 数据源的setter方法
- (void)setDataSource:(id<NLDropDownMenuDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    _dataSourceFlags.numberOfRowsInColumn = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)];
    _dataSourceFlags.titleForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    
    
    for (int i = 0; i < _numOfMenu; i++) {
        float titleW = (self.frame.size.width - (_numOfMenu-1))/_numOfMenu;
        float titleH = self.frame.size.height - 1;
        float titleX = i * (titleW + 1);
        float titleY = 0;
        
        
        NSString *titleString =[_dataSource menu:self titleForRowAtIndexPath:[NLIndexPath indexPathWithCol:i row:0]];
        
        
        NLTapLabel *title = [NLTapLabel LabelWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
        title.index = i;
        title.textColor = self.textColor;
        title.font = [UIFont systemFontOfSize:self.fontSize];
        title.text = titleString;
        
        
        [self.titles addObject:title];
        
        [self addSubview:title];
        __weak typeof(self) weakSelf = self;
        [title setAction:^(NLTapLabel *alabel) {
            
            [weakSelf dealMenuTap:(NLTapLabel *)alabel];
            
        }];
        
        
    }
    
}

#pragma mark -
#pragma mark 处理背景点击
- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableView:_tableView show:NO complete:^{
            _show = NO;
        }];
    }];
}

#pragma mark 处理menu点击
-(void)dealMenuTap:(NLTapLabel *)alabel{
    for (NLTapLabel *label in self.titles) {
        label.textColor = self.textColor;
    }
    
    int tapIndex = alabel.index;
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        
        [self animateBackGroundView:_backGroundView show:NO complete:^{
            [self animateTableView:_tableView show:NO complete:^{
                _currentSelectedMenudIndex = tapIndex;
                _show = NO;
            }];
        }];
        
    }else {
        alabel.textColor = self.textSelectedColor;
        _currentSelectedMenudIndex = tapIndex;
        [_tableView reloadData];
        [self animateBackGroundView:_backGroundView show:YES complete:^{
            [self animateTableView:_tableView show:YES complete:^{
                _show = YES;
            }];
        }];
        
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            for (NLTapLabel *title in self.titles) {
                title.textColor = kTextColor;
            }
        }];
    }
    complete();
}

- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete {
  
    if (show) {
        
        _tableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        [self.superview addSubview:_tableView];
        
        CGFloat tableViewHeight = kTableViewHeight;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _tableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            _tableView.tableFooterView = [[UIView alloc]init];
            _tableView.showsVerticalScrollIndicator = NO;
            
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{

            _tableView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            
        } completion:^(BOOL finished) {
            [_tableView removeFromSuperview];
        }];
    }
    complete();
}



#pragma mark - tableView 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(_dataSource != nil, @"menu's dataSource shouldn't be nil");

    if (_dataSourceFlags.numberOfRowsInColumn) {
        return [_dataSource menu:self
            numberOfRowsInColumn:_currentSelectedMenudIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DropDownMenuCell *cell = [DropDownMenuCell cell];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //        cell.textLabel.highlightedTextColor = kTextSelectColor;
    cell.textLabel.textColor = kTextColor;
    
    if (_dataSourceFlags.titleForRowAtIndexPath) {
        cell.textLabel.text = [_dataSource menu:self titleForRowAtIndexPath:[NLIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
    } else {
        NSAssert(0 == 1, @"dataSource method needs to be implemented");
    }
    
    cell.backgroundColor = kCellBgColor;
    cell.checkView.hidden = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:_fontSize];
    
    NLTapLabel *label = [_titles objectAtIndex:_currentSelectedMenudIndex];
    
    if ([cell.textLabel.text isEqualToString:label.text]) {
        [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        cell.checkView.hidden = NO;
        
    }
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    _currentSelectedMenudRow = indexPath.row;
    
    NLTapLabel *title = self.titles[_currentSelectedMenudIndex];
    
    title.text = [_dataSource menu:self titleForRowAtIndexPath:[NLIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]];
    title.textColor = kTextColor;
    
    [_delegate menu:self didSelectRowAtIndexPath:[NLIndexPath indexPathWithCol:_currentSelectedMenudIndex row:_currentSelectedMenudRow]];
    
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableView:_tableView show:NO complete:^{
            _show = NO;
        }];
    }];
}

@end



#pragma mark - 定义可点击的Label
@implementation NLTapLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        
        self.textColor = kTextColor;
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeCenter;
        self.textAlignment = NSTextAlignmentCenter;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

+(instancetype)LabelWithFrame:(CGRect)frame {
    
    return [[self alloc]initWithFrame:frame];
}

-(void)dealTap:(UITapGestureRecognizer *)tap{
    
    if (self.action) {
        self.action(self);
    }
}

@end

