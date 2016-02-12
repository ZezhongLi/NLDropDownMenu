//
//  DropDownMenuCell.h
//  NLDropDownMenuDemo
//
//  Created by Neil-Lee on 15/5/13.
//  Copyright (c) 2015年 Neil-Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropDownMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *checkView;

+(instancetype)cell;
@end
