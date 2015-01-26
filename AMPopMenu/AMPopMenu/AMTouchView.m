//
//  AMTouchView.m
//  PopTipDemo
//
//  Created by renhe on 15/1/26.
//  Copyright (c) 2015年 Fancy Pixel. All rights reserved.
//

#import "AMTouchView.h"

@interface AMTouchView()
@property(nonatomic)BOOL touchBegin;
@end

@implementation AMTouchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchBegin = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touchBegin) {
        self.touchBegin = NO;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touchBegin) {
        self.touchBegin = NO;
        
        if ([self.delegate respondsToSelector:@selector(touchViewTapped:)]) {
            [self.delegate touchViewTapped:self];
        }
    }
}

@end
