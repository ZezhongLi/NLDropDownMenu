//
//  DropDownMenuCell.m
//  NLDropDownMenuDemo
//
//  Created by Neil-Lee on 15/5/13.
//  Copyright (c) 2015年 Neil-Lee. All rights reserved.
//

#import "DropDownMenuCell.h"

@implementation DropDownMenuCell


+(instancetype)cell {
    return [[NSBundle mainBundle]loadNibNamed:@"DropDownMenuCell" owner:nil options:nil][0];
}


@end
