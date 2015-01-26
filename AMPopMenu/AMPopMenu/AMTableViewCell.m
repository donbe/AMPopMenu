//
//  AMTableViewCell.m
//  PopTipDemo
//
//  Created by renhe on 15/1/26.
//  Copyright (c) 2015年 Fancy Pixel. All rights reserved.
//

#define kDefaultLineHeight 1
#define kDefaultTitleFontSize 14
#define kDefaultShowBottomLine YES
#define kDefaultTitleEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)



#import "AMTableViewCell.h"

@interface AMTableViewCell()

@property(nonatomic,strong) UIImageView *bottomLine; //下分割线

@end

@implementation AMTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (self.titleLabel==nil) {
            self.titleLabel = [UILabel new];
            self.titleLabel.backgroundColor = [UIColor clearColor];
            self.titleLabel.font = [UIFont systemFontOfSize:kDefaultTitleFontSize];
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.textAlignment  = NSTextAlignmentLeft;
            [self addSubview:_titleLabel];
        }
        
        if (self.bottomLine==nil) {
            self.bottomLine = [[UIImageView alloc] initWithFrame:CGRectZero];
            self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
            [self addSubview:_bottomLine];
        }
        
        _showBottomLine = kDefaultShowBottomLine;
    }
    return self;
}

-(void)setBottomLineColor:(UIColor *)bottomLineColor{
    _bottomLineColor = bottomLineColor;
    _bottomLine.image = [self imageWithColor:bottomLineColor];
}


-(UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = (CGRect){
        {kDefaultTitleEdgeInsets.left,kDefaultTitleEdgeInsets.top},
        {self.bounds.size.width-kDefaultTitleEdgeInsets.left-kDefaultTitleEdgeInsets.right,self.bounds.size.height-kDefaultTitleEdgeInsets.top-kDefaultTitleEdgeInsets.bottom}
    };
    _bottomLine.frame = CGRectMake(0, self.frame.size.height-kDefaultLineHeight, self.frame.size.width, kDefaultLineHeight);
    _bottomLine.alpha = _showBottomLine;
}


@end
