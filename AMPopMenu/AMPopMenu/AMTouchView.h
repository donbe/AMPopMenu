//
//  AMTouchView.h
//  PopTipDemo
//
//  Created by renhe on 15/1/26.
//  Copyright (c) 2015年 Fancy Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMTouchView;


@protocol AMTouchViewDelegate <NSObject>

-(void)touchViewTapped:(AMTouchView *)touchView;

@end

@interface AMTouchView : UIView

@property(nonatomic,weak)id<AMTouchViewDelegate>delegate;

@end
