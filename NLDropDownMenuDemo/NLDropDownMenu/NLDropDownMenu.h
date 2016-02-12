//
//  NLDropDownMenu.h
//  NLDropDownMenuDemo
//
//  Created by Neil-Lee on 15/5/13.
//  Copyright (c) 2015年 Neil-Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
// default item = -1
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;
@end


@interface NLCellView : UIView

@end




#pragma mark - data source protocol
@class NLDropDownMenu;

@protocol NLDropDownMenuDataSource <NSObject>

@required

/**
 *  返回 menu 第column列有多少行
 */
- (NSInteger)menu:(NLDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;

/**
 *  返回 menu 第column列 每行title
 */
- (NSString *)menu:(NLDropDownMenu *)menu titleForRowAtIndexPath:(NLIndexPath *)indexPath;

@optional
/**
 *  返回 menu 有多少列 ，默认1列
 */
- (NSInteger)numberOfColumnsInMenu:(NLDropDownMenu *)menu;

@end

#pragma mark - delegate
@protocol NLDropDownMenuDelegate <NSObject>
@optional
/**
 *  点击代理，点击了第column 第row 或者item项，如果 item >=0
 */
- (void)menu:(NLDropDownMenu *)menu didSelectRowAtIndexPath:(NLIndexPath *)indexPath;
@end

#pragma mark - interface
@interface NLDropDownMenu : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <NLDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <NLDropDownMenuDelegate> delegate;

@property (nonatomic, strong) UIColor *textColor;           // 文字title颜色
@property (nonatomic, strong) UIColor *textSelectedColor;   // 文字title选中颜色
@property (nonatomic, strong) UIColor *separatorColor;      // 分割线颜色
@property (nonatomic, assign) NSInteger fontSize;           // 字体大小
@property (nonatomic, strong) UIColor *cellBgColor;           // 文字title颜色


/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

// 获取title
- (NSString *)titleForRowAtIndexPath:(NLIndexPath *)indexPath;

// 创建menu 第一次显示 不会调用点击代理，这个手动调用
- (void)selectDefalutIndexPath:(NLIndexPath *)indexPath;

@end

@interface NLTapLabel : UILabel

@property (assign,nonatomic) int index;

@property (copy,nonatomic) void (^action)(NLTapLabel *label);

+(instancetype)LabelWithFrame:(CGRect)frame;

@end

