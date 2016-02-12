//
//  ViewController.m
//  NLDropDownMenuDemo
//
//  Created by Neil-Lee on 15/5/13.
//  Copyright (c) 2015年 Neil-Lee. All rights reserved.
//

#import "ViewController.h"
#import "NLDropDownMenu.h"

@interface ViewController ()<NLDropDownMenuDataSource,NLDropDownMenuDelegate>
@property (strong,nonatomic) NSArray * distance;
@property (strong,nonatomic) NSArray * category;
@property (strong,nonatomic) NSArray * orderRule;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.distance = @[@"1km",@"2km",@"5km",@"10km"];
    self.category = @[@"餐饮美食",@"娱乐休闲",@"生活服务",@"电影演出",@"商场超市",@"电子优惠",@"摄像写真"];
    self.orderRule = @[@"默认",@"购买量优先",@"价格优先"];
    
    NLDropDownMenu *menu = [[NLDropDownMenu alloc]initWithOrigin:CGPointMake(0, 64) andHeight:50];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
    
}

#pragma mark - menu的数据源和代理方法
- (NSInteger)numberOfColumnsInMenu:(NLDropDownMenu *)menu
{
    return 3;
}

- (NSInteger)menu:(NLDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if (column == 0) {
        return self.distance.count;
    }else if (column == 1){
        return self.category.count;
    }else {
        return self.orderRule.count;
    }
}

- (NSString *)menu:(NLDropDownMenu *)menu titleForRowAtIndexPath:(NLIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        return self.distance[indexPath.row];
    } else if (indexPath.column == 1){
        return self.category[indexPath.row];
    } else {
        return self.orderRule[indexPath.row];
    }
}

- (void)menu:(NLDropDownMenu *)menu didSelectRowAtIndexPath:(NLIndexPath *)indexPath
{
    
    NSLog(@"点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
    

    
}


@end
