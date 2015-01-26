//
//  ViewController.m
//  AMPopMenu
//
//  Created by renhe on 15/1/26.
//  Copyright (c) 2015年 donbe. All rights reserved.
//

#import "ViewController.h"
#import "AMPopMenu.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *buttonTopLeft;
@property (nonatomic, weak) IBOutlet UIButton *buttonTopRight;
@property (nonatomic, weak) IBOutlet UIButton *buttonBottomLeft;
@property (nonatomic, weak) IBOutlet UIButton *buttonBottomRight;
@property (nonatomic, weak) IBOutlet UIButton *buttonCenter;

@property (nonatomic, strong) AMPopMenu *popTip;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[AMPopMenu appearance] setFont:[UIFont fontWithName:@"Avenir-Medium" size:12]];
    
    self.popTip = [AMPopMenu popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.font = [UIFont systemFontOfSize:14];
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.popTip.tapHandler = ^(NSInteger index){
        NSLog(@"%ld",(long)index);
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
}

- (IBAction)actionButton:(UIButton *)sender
{
    [self.popTip hide];
    
    if ([self.popTip isVisible]) {
        return;
    }
    
    if (sender == self.buttonTopLeft) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.95 green:0.65 blue:0.21 alpha:1];
        [self.popTip showMenus:@[@"buttonTopLeft",@"balabala"] direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonTopRight) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.97 green:0.9 blue:0.23 alpha:1];
        [self.popTip showMenus:@[@"buttonTopRight"] direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonBottomLeft) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.73 green:0.91 blue:0.55 alpha:1];
        [self.popTip showMenus:@[@"buttonBottomLeft"] direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonBottomRight) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.81 green:0.04 blue:0.14 alpha:1];
        [self.popTip showMenus:@[@"buttonBottomRight"] direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:sender.frame];
    }
    if (sender == self.buttonCenter) {
        self.popTip.popoverColor = [UIColor colorWithRed:0.31 green:0.57 blue:0.87 alpha:1];
        static int direction = 0;
        [self.popTip showMenus:@[@"buttonCenterbuttonCenterbuttonCenterbuttonCenter"] direction:direction maxWidth:200 inView:self.view fromFrame:sender.frame duration:0];
        direction = (direction + 1) % 4;
    }
}

@end
