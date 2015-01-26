//
//  AMTableViewCell.h
//  PopTipDemo
//
//  Created by renhe on 15/1/26.
//  Copyright (c) 2015年 Fancy Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMTableViewCell : UITableViewCell

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIColor *bottomLineColor;
@property(nonatomic) BOOL showBottomLine;
@end
