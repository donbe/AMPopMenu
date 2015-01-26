//
//  AMPopTip.m
//  PopTipDemo
//
//  Created by Andrea Mazzini on 11/07/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "AMPopMenu.h"
#import "AMTouchView.h"
#import "AMTableViewCell.h"

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

#define kDefaultFont [UIFont systemFontOfSize:[UIFont systemFontSize]]
#define kDefaultTextColor [UIColor whiteColor]
#define kDefaultBackgroundColor [UIColor redColor]
#define kDefaultBorderColor [UIColor colorWithWhite:0.182 alpha:1.000]
#define kDefaultBorderWidth 0
#define kDefaultRadius 4
#define kDefaultPadding 6
#define kDefaultArrowSize CGSizeMake(8, 8)
#define kDefaultAnimationIn 0.4
#define kDefaultAnimationOut 0.2
#define kDefaultEdgeInsets UIEdgeInsetsZero
#define kDefaultOffset 0
#define kDefaultRowHeight 30.0
#define kDefaultRowSelectedColor [UIColor colorWithWhite:0.0 alpha:0.1]
#define kDefaultRowSeparatorColor [UIColor colorWithWhite:0.0 alpha:0.1]

@interface AMPopMenu()<UITableViewDelegate,UITableViewDataSource,AMTouchViewDelegate>

//@property (nonatomic, strong) NSString *text;
//@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
//@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
//@property (nonatomic, strong) UITapGestureRecognizer *removeGesture;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, weak  ) UIView *containerView;
@property (nonatomic, assign) AMPopTipDirection direction;
@property (nonatomic, assign) CGRect menuBounds;
@property (nonatomic, assign) CGPoint arrowPosition;
@property (nonatomic, assign) CGFloat maxWidth;

/**
 *  cmh 菜单数组
 */
@property (nonatomic, strong) NSArray *menus;
/**
 *  cmh 菜单tableview
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  底部touchview
 */
@property(nonatomic,strong)AMTouchView *touchView;

@end

@implementation AMPopMenu

+ (instancetype)popTip
{
    return [[AMPopMenu alloc] init];
}

- (instancetype)initWithFrame:(CGRect)ignoredFrame
{
    return [self init];
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        _textAlignment = NSTextAlignmentCenter;
        _font = kDefaultFont;
        _textColor = kDefaultTextColor;
        _popoverColor = kDefaultBackgroundColor;
        _borderColor = kDefaultBorderColor;
        _borderWidth = kDefaultBorderWidth;
        _radius = kDefaultRadius;
        _padding = kDefaultPadding;
        _arrowSize = kDefaultArrowSize;
        _animationIn = kDefaultAnimationIn;
        _animationOut = kDefaultAnimationOut;
        _isVisible = NO;
        _shouldDismissOnTapOutside = YES;
        _edgeMargin = 0;
        _edgeInsets = kDefaultEdgeInsets;
        _rounded = NO;
        _offset = kDefaultOffset;
//        _removeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGestureHandler)];
        
        /**
         *  cmh
         */
        _rowHeight = kDefaultRowHeight;
        _rowSelectedColor = kDefaultRowSelectedColor;
        _rowSeparatorColor = kDefaultRowSeparatorColor;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        _touchView = [[AMTouchView alloc] initWithFrame:self.containerView.bounds];
        _touchView.delegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [self setup];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    if (self.isRounded) {
        BOOL showHorizontally = self.direction == AMPopTipDirectionLeft || self.direction == AMPopTipDirectionRight;
        self.radius = (self.frame.size.height - (showHorizontally ? 0 : self.arrowSize.height)) / 2 ;
    }
    
    CGRect baloonFrame;
    // Drawing a round rect and the arrow alone sometime show a white halfpixel line, so here's a fun bit of code...
    switch (self.direction) {
        case AMPopTipDirectionNone: {
            baloonFrame = (CGRect){ (CGPoint) { self.borderWidth, self.borderWidth }, (CGSize){ self.frame.size.width - self.borderWidth * 2, self.frame.size.height - self.borderWidth * 2} };
            path = [UIBezierPath bezierPathWithRoundedRect:baloonFrame cornerRadius:self.radius];
            
            break;
        }
        case AMPopTipDirectionDown: {
            baloonFrame = (CGRect){ (CGPoint) { 0, self.arrowSize.height }, (CGSize){ rect.size.width - self.borderWidth * 2, rect.size.height - self.arrowSize.height - self.borderWidth * 2} };
            
            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x + self.arrowSize.width / 2, self.arrowPosition.y + self.arrowSize.height }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius, self.arrowSize.height }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius,  self.arrowSize.height + self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width, self.arrowSize.height + baloonFrame.size.height - self.radius }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius,  self.arrowSize.height + baloonFrame.size.height - self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.radius, self.arrowSize.height + baloonFrame.size.height }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius,  self.arrowSize.height + baloonFrame.size.height - self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth, self.arrowSize.height + self.radius }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, self.arrowSize.height + self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x - self.arrowSize.width / 2, self.arrowPosition.y + self.arrowSize.height }];
            [path closePath];
            
            break;
        }
        case AMPopTipDirectionUp: {
            baloonFrame = (CGRect){ (CGPoint) { 0, 0 }, (CGSize){ rect.size.width - self.borderWidth * 2, rect.size.height - self.arrowSize.height - self.borderWidth * 2 } };
            
            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y - self.borderWidth }];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x + self.arrowSize.width / 2, self.arrowPosition.y - self.arrowSize.height - self.borderWidth }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + baloonFrame.size.height + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(0) clockwise:NO];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width, baloonFrame.origin.y + self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(180) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(90) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x - self.arrowSize.width / 2, self.arrowPosition.y - self.arrowSize.height - self.borderWidth }];
            [path closePath];
            
            break;
        }
        case AMPopTipDirectionLeft: {
            baloonFrame = (CGRect){ (CGPoint) { 0, 0 }, (CGSize){ rect.size.width - self.arrowSize.width - self.borderWidth * 2, rect.size.height - self.borderWidth * 2} };
            
            [path moveToPoint:(CGPoint){ self.arrowPosition.x - self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x - self.arrowSize.width - self.borderWidth, self.arrowPosition.y - self.arrowSize.height / 2 }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.borderWidth, baloonFrame.origin.y + self.radius }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(180) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(90) clockwise:NO];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius -  self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius -  self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(0) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x - self.arrowSize.width - self.borderWidth, self.arrowPosition.y + self.arrowSize.height / 2 }];
            [path closePath];
            
            break;
        }
        case AMPopTipDirectionRight: {
            baloonFrame = (CGRect){ (CGPoint) { self.arrowSize.width, 0 }, (CGSize){ rect.size.width - self.arrowSize.width - self.borderWidth * 2, rect.size.height - self.borderWidth * 2} };
            
            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x + self.arrowSize.width + self.borderWidth, self.arrowPosition.y - self.arrowSize.height / 2 }];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth} radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x + self.arrowSize.width + self.borderWidth, self.arrowPosition.y + self.arrowSize.height / 2 }];
            [path closePath];
            
            break;
        }
    }
    
    [self.popoverColor setFill];
    [path fill];
    
    [self.borderColor setStroke];
    [path setLineWidth:self.borderWidth];
    [path stroke];
    
    self.paragraphStyle.alignment = self.textAlignment;
    
    //    NSDictionary *titleAttributes = @{
    //                                      NSParagraphStyleAttributeName: self.paragraphStyle,
    //                                      NSFontAttributeName: self.font,
    //                                      NSForegroundColorAttributeName: self.textColor
    //                                      };
    
    //    if (self.text != nil) {
    //        [self.text drawInRect:self.menuBounds withAttributes:titleAttributes];
    //    } else if (self.attributedText != nil) {
    //        [self.attributedText drawInRect:self.menuBounds];
    //    }
}

- (void)dealloc
{
    //    [_removeGesture removeTarget:self action:@selector(removeGestureHandler)];
    //    _removeGesture = nil;
}
- (void)setup
{
    
    if (self.direction == AMPopTipDirectionLeft) {
        self.maxWidth = MIN(self.maxWidth, self.fromFrame.origin.x - self.padding * 2 - self.edgeInsets.left - self.edgeInsets.right - self.arrowSize.width);
    }
    if (self.direction == AMPopTipDirectionRight) {
        self.maxWidth = MIN(self.maxWidth, self.containerView.bounds.size.width - self.fromFrame.origin.x - self.fromFrame.size.width - self.padding * 2 - self.edgeInsets.left - self.edgeInsets.right - self.arrowSize.width);
    }

    _tableView.separatorColor = _rowSeparatorColor;
    
    CGFloat menuMaxWidth = 0.0;
    for (NSString *menu in self.menus) {
        CGSize menuSize;
        
        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)) {
            menuSize = [menu sizeWithAttributes:@{NSFontAttributeName:self.font}];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            menuSize = [menu sizeWithFont:self.font];
#pragma clang diagnostic pop
        }
        
        menuMaxWidth = MAX(menuMaxWidth, menuSize.width+20);
    }
    menuMaxWidth = MIN(self.maxWidth, menuMaxWidth);

//    if (self.text != nil) {
//        self.menuBounds = [self.text boundingRectWithSize:(CGSize){self.maxWidth, DBL_MAX }
//                                                  options:NSStringDrawingUsesLineFragmentOrigin
//                                               attributes:@{NSFontAttributeName: self.font}
//                                                  context:nil];
//    } else if (self.attributedText != nil) {
//        self.menuBounds = [self.attributedText boundingRectWithSize:(CGSize){self.maxWidth, DBL_MAX }
//                                                            options:NSStringDrawingUsesLineFragmentOrigin
//                                                            context:nil];
//    }

    _menuBounds = (CGRect){{self.padding + self.edgeInsets.left, self.padding + self.edgeInsets.top},{menuMaxWidth,_rowHeight*[_menus count]}};
    _tableView.frame = _menuBounds;
    
    CGRect frame = CGRectZero;
    float offset = self.offset * ((self.direction == AMPopTipDirectionUp || self.direction == AMPopTipDirectionLeft || self.direction == AMPopTipDirectionNone) ? -1 : 1);
    
    if (self.direction == AMPopTipDirectionUp || self.direction == AMPopTipDirectionDown) {
        frame.size = (CGSize){self.menuBounds.size.width + self.padding * 2.0 + self.edgeInsets.left + self.edgeInsets.right, self.menuBounds.size.height + self.padding * 2.0 + self.edgeInsets.top + self.edgeInsets.bottom + self.arrowSize.height};
        
        CGFloat x = self.fromFrame.origin.x + self.fromFrame.size.width / 2 - frame.size.width / 2;
        if (x < 0) { x = self.edgeMargin; }
        if (x + frame.size.width > self.containerView.bounds.size.width) { x = self.containerView.bounds.size.width - frame.size.width - self.edgeMargin; }
        if (self.direction == AMPopTipDirectionDown) {
            frame.origin = (CGPoint){ x, self.fromFrame.origin.y + self.fromFrame.size.height };
        } else {
            frame.origin = (CGPoint){ x, self.fromFrame.origin.y - frame.size.height};
        }
        
        frame.origin.y += offset;
        
    } else if (self.direction == AMPopTipDirectionLeft || self.direction == AMPopTipDirectionRight) {
        frame.size = (CGSize){ self.menuBounds.size.width + self.padding * 2.0 + self.edgeInsets.left + self.edgeInsets.right + self.arrowSize.width, self.menuBounds.size.height + self.padding * 2.0 + self.edgeInsets.top + self.edgeInsets.bottom};
        
        CGFloat x = 0;
        if (self.direction == AMPopTipDirectionLeft) {
            x = self.fromFrame.origin.x - frame.size.width;
        }
        if (self.direction == AMPopTipDirectionRight) {
            x = self.fromFrame.origin.x + self.fromFrame.size.width;
        }
        
        x += offset;
        
        CGFloat y = self.fromFrame.origin.y + self.fromFrame.size.height / 2 - frame.size.height / 2;
        
        if (y < 0) { y = self.edgeMargin; }
        if (y + frame.size.height > self.containerView.bounds.size.height) { y = self.containerView.bounds.size.height - frame.size.height - self.edgeMargin; }
        frame.origin = (CGPoint){ x, y };
    } else {
        frame.size = (CGSize){ self.menuBounds.size.width + self.padding * 2.0 + self.edgeInsets.left + self.edgeInsets.right, self.menuBounds.size.height + self.padding * 2.0 + self.edgeInsets.top + self.edgeInsets.bottom };
        frame.origin = (CGPoint){ CGRectGetMidX(self.fromFrame) - frame.size.width / 2, CGRectGetMidY(self.fromFrame) - frame.size.height / 2 + offset };
    }
    
    frame.size = (CGSize){ frame.size.width + self.borderWidth * 2, frame.size.height + self.borderWidth * 2 };
    
    switch (self.direction) {
        case AMPopTipDirectionNone: {
            self.arrowPosition = CGPointZero;
            self.layer.anchorPoint = (CGPoint){ 0.5, 0.5 };
            self.layer.position = (CGPoint){ CGRectGetMidX(self.fromFrame), CGRectGetMidY(self.fromFrame) };
            break;
        }
        case AMPopTipDirectionDown: {
            self.arrowPosition = (CGPoint){
                self.fromFrame.origin.x + self.fromFrame.size.width / 2 - frame.origin.x,
                self.fromFrame.origin.y + self.fromFrame.size.height - frame.origin.y + offset
            };
            CGFloat anchor = self.arrowPosition.x / frame.size.width;
            _menuBounds.origin = (CGPoint){ self.menuBounds.origin.x, self.menuBounds.origin.y + self.arrowSize.height };
            _tableView.frame = _menuBounds;
            self.layer.anchorPoint = (CGPoint){ anchor, 0 };
            self.layer.position = (CGPoint){ self.layer.position.x + frame.size.width * anchor, self.layer.position.y - frame.size.height / 2 };
            
            break;
        }
        case AMPopTipDirectionUp: {
            self.arrowPosition = (CGPoint){
                self.fromFrame.origin.x + self.fromFrame.size.width / 2 - frame.origin.x,
                frame.size.height
            };
            CGFloat anchor = self.arrowPosition.x / frame.size.width;
            self.layer.anchorPoint = (CGPoint){ anchor, 1 };
            self.layer.position = (CGPoint){ self.layer.position.x + frame.size.width * anchor, self.layer.position.y + frame.size.height / 2 };
            
            break;
        }
        case AMPopTipDirectionLeft: {
            self.arrowPosition = (CGPoint){
                self.fromFrame.origin.x - frame.origin.x + offset,
                self.fromFrame.origin.y + self.fromFrame.size.height / 2 - frame.origin.y
            };
            CGFloat anchor = self.arrowPosition.y / frame.size.height;
            self.layer.anchorPoint = (CGPoint){ 1, anchor };
            self.layer.position = (CGPoint){ self.layer.position.x - frame.size.width / 2, self.layer.position.y + frame.size.height * anchor };
            
            break;
        }
        case AMPopTipDirectionRight: {
            self.arrowPosition = (CGPoint){
                self.fromFrame.origin.x + self.fromFrame.size.width - frame.origin.x + offset,
                self.fromFrame.origin.y + self.fromFrame.size.height / 2 - frame.origin.y
            };
            _menuBounds.origin = (CGPoint){ self.menuBounds.origin.x + self.arrowSize.width, self.menuBounds.origin.y };
            _tableView.frame = _menuBounds;
            CGFloat anchor = self.arrowPosition.y / frame.size.height;
            self.layer.anchorPoint = (CGPoint){ 0, anchor };
            self.layer.position = (CGPoint){ self.layer.position.x + frame.size.width / 2, self.layer.position.y + frame.size.height * anchor };
            
            break;
        }
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = frame;
    
//    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    [self addGestureRecognizer:self.gestureRecognizer];
    [self setNeedsDisplay];
}

//- (void)handleTap:(UITapGestureRecognizer *)gesture
//{
//    if (self.shouldDismissOnTap) {
//        [self hide];
//    }
//    if (self.tapHandler) {
//        self.tapHandler();
//    }
//}

//- (void)removeGestureHandler
//{
//    if (self.shouldDismissOnTapOutside) {
//        [self hide];
//    }
//}



- (void)show
{
    [self setNeedsLayout];
    [self.tableView reloadData];
    
    _touchView.frame = _containerView.bounds;
    [self.containerView addSubview:_touchView];
    
    self.transform = CGAffineTransformMakeScale(0, 0);
    [self.containerView addSubview:self];
    _isVisible = YES;
    
    [UIView animateWithDuration:self.animationIn delay:self.delayIn usingSpringWithDamping:0.6 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL completed){
        if (completed) {
//            [self.containerView addGestureRecognizer:self.removeGesture];
            if (self.appearHandler) {
                self.appearHandler();
            }
        }
    }];
}

- (void)hide
{
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
    //    [self.containerView removeGestureRecognizer:self.removeGesture];
    [_touchView removeFromSuperview];
    
    if (self.superview) {
        [UIView animateWithDuration:self.animationOut delay:self.delayOut options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeFromSuperview];
                self.transform = CGAffineTransformIdentity;
                self->_isVisible = NO;
                if (self.dismissHandler) {
                    self.dismissHandler();
                }
            }
        }];
    }
}



//- (void)showText:(NSString *)text direction:(AMPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(UIView *)view fromFrame:(CGRect)frame
//{
//    self.direction = direction;
//    self.containerView = view;
//    self.maxWidth = maxWidth;
//    _fromFrame = frame;
//    
//    [self show];
//}

//- (void)showAttributedText:(NSAttributedString *)text direction:(AMPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(UIView *)view fromFrame:(CGRect)frame
//{
//    self.direction = direction;
//    self.containerView = view;
//    self.maxWidth = maxWidth;
//    _fromFrame = frame;
//    
//    [self show];
//}


-(void)showMenus:(NSArray *)menus direction:(AMPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(UIView *)view fromFrame:(CGRect)frame{
    self.menus = menus;
    self.direction = direction;
    self.containerView = view;
    self.maxWidth = maxWidth;
    _fromFrame = frame;
    
    [self show];
}

- (void)showMenus:(NSArray *)menus direction:(AMPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(UIView *)view fromFrame:(CGRect)frame duration:(NSTimeInterval)interval
{
    [self showMenus:menus direction:direction maxWidth:maxWidth inView:view fromFrame:frame];
    [self.dismissTimer invalidate];
    if (interval > 0) {
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                             target:self
                                                           selector:@selector(hide)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}


#pragma mark - get/set
- (void)setFromFrame:(CGRect)fromFrame
{
    _fromFrame = fromFrame;
    [self setup];
}

//- (void)showAttributedText:(NSAttributedString *)text direction:(AMPopTipDirection)direction maxWidth:(CGFloat)maxWidth inView:(UIView *)view fromFrame:(CGRect)frame duration:(NSTimeInterval)interval
//{
//    [self showAttributedText:text direction:direction maxWidth:maxWidth inView:view fromFrame:frame];
//    [self.dismissTimer invalidate];
//    if(interval > 0){
//        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval
//                                                             target:self
//                                                           selector:@selector(hide)
//                                                           userInfo:nil
//                                                            repeats:NO];
//    }
//}


//- (void)updateText:(NSString *)text
//{
//    self.text = text;
//    self.accessibilityLabel = text;
//    [self setNeedsLayout];
//}




#pragma mark - tableview delegata ,datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 0;
    return [_menus count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AMTableViewCell"];
    if (!cell) {
        cell = [[AMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AMTableViewCell"];
        cell.backgroundColor =[UIColor clearColor];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = _rowSelectedColor;
        cell.titleLabel.textColor = _textColor;
        cell.titleLabel.font = _font;
        if (_rowSeparatorColor) {
            cell.bottomLineColor = _rowSeparatorColor;
        }else{
            cell.bottomLineColor = kDefaultRowSeparatorColor;
        }
    }
    if (indexPath.row == (NSInteger)[_menus count]-1) {
        cell.showBottomLine = NO;
    }else{
        cell.showBottomLine = YES;
    }
    
    cell.titleLabel.text = _menus[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.shouldDismissOnTap) {
        [self hide];
    }
    if (self.tapHandler) {
        self.tapHandler(indexPath.row);
    }
}

#pragma mark - AMTouchViewDelegate
-(void)touchViewTapped:(AMTouchView *)touchView{
    if (self.shouldDismissOnTapOutside) {
        [self hide];
    }
}
@end

