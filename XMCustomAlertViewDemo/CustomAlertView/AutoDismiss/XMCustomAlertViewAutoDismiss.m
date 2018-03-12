//
//  XMCustomAlertViewAutoDismiss.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/23.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewAutoDismiss.h"
#import <objc/runtime.h>


@interface _XMCustomAlertViewAutoDismissView : UIView

@property (nonatomic, strong) UILabel *label;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)popoShortMsgWithSuperView:(UIView*)superView;
- (void)popoShortMsgWithSuperViewInTime:(UIView*)superView inTime:(NSTimeInterval)time;
- (void)setMsg:(NSString*)msg;

@end

@implementation _XMCustomAlertViewAutoDismissView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:frame])
    {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.9;
        _label = nil;
        
#ifndef SHORT_MSG_SELF_DRAW
        NSString *imageName = @"msg_box.png";
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *pathName = [NSString stringWithFormat:@"%@/%@", bundlePath, imageName];
        UIImage *image = [UIImage imageWithContentsOfFile:pathName];
        
        //frame.size.height = image.size.height; //调整高度
        UIImage *strechImage = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        [imageView setImage:strechImage];
        
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
        self.autoresizesSubviews = YES;
#endif
    }
    return self;
}

#ifdef SHORT_MSG_SELF_DRAW
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘制圆角矩形
    CGFloat ovalWidth = 10;
    CGFloat ovalHeight = 10;
    CGFloat fw,fh;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context,CGRectGetMinX(rect) ,CGRectGetMinY(rect));
    CGContextScaleCTM(context,ovalWidth,ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context,fw,fh/2); // start lower-right corner
    CGContextAddArcToPoint(context,fw,fh,fw/2,fh,1);//top-right corner
    CGContextAddArcToPoint(context,0,fh,0,fh/2,1);// top-left corner
    CGContextAddArcToPoint(context,0,0,fw/2,0,1); // lower-left corner
    CGContextAddArcToPoint(context,fw,0,fw,fh,1); // back to lower-right corner
    
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetStrokeColorWithColor(context,[UIColor blackColor].CGColor);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}
#endif


-(void)timerHideAnimationDidStop:(NSString*)animatinID context:(void*)context
{
    [self removeFromSuperview];
}

-(void)timerHide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];

    self.alpha = 0;
    [UIView commitAnimations];
}

-(void)timerHideDelay
{
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerHide) userInfo:nil repeats:NO];
}

-(void)popoShortMsgWithSuperView:(UIView*)superView
{
    self.alpha = 0;
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(timerHideDelay)];
    
    self.alpha = 1;
    
    [UIView commitAnimations];
}
-(void)popoShortMsgWithSuperViewInTime:(UIView*)superView inTime:(NSTimeInterval)time
{
    self.alpha = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    
    self.alpha = 1;
    
    [UIView commitAnimations];
    
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerHide) userInfo:nil repeats:NO];
}
-(void)setMsg:(NSString*)msg
{
    if( _label == nil )
    {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        
        [self addSubview:_label];
        [self bringSubviewToFront:_label];
    }
    else {
        _label.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
    }

    _label.text = msg;
    
#ifdef SHORT_MSG_SELF_DRAW
    // 自绘制的时候需要
    [self setNeedsDisplay];
#endif
}

- (void)dealloc 
{
    [_label removeFromSuperview];
    
    if( self.superview != nil )
    {
        [self removeFromSuperview];
    }
}

@end


@interface XMCustomAlertView (PAutoDismiss)

@property (nonatomic, strong) _XMCustomAlertViewAutoDismissView *autoDismissView;
@property (nonatomic, weak) UIView *xmSuperView;
@property (nonatomic, strong) UIView *contentView;

@end

static char KAutoDismissViewKey;

@implementation XMCustomAlertView (AutoDismiss)

- (void)showInSuperView:(UIView *)superView
{
    self.xmSuperView = superView;
    [self show];
}

- (void)showAutoDismissTips:(NSString *)tips
{
    [self showAutoDismissTips:tips delayTime:2.f];
}

- (void)showAutoDismissTips:(NSString *)tips delayTime:(NSTimeInterval)delayTime
{
    UIDevice* pDevice = [UIDevice currentDevice];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIView *superView = self.contentView;
#pragma clang diagnostic pop
    
    if( superView == nil || pDevice == nil ) {
        return;
    }
    
    CGRect frame = [superView bounds];
    CGFloat fontsize = [UIFont labelFontSize];
    frame.origin.y += frame.size.height * 0.382/*黄金分割点*/ ;
    frame.size.height = fontsize + 30;
    
    // 默认为一屏幕宽度
    if( self.autoDismissView == nil )
    {
        self.autoDismissView = [[_XMCustomAlertViewAutoDismissView alloc] initWithFrame:frame];
    }
    
    CGSize sizeDraw = [tips boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont labelFontSize]]} context:nil].size;
    // 对于单行不超过本身宽度的str，使用str的实际绘制长度
    if( sizeDraw.width  + 10 < frame.size.width )
    {
        frame.origin.x += (frame.size.width - sizeDraw.width - 10) / 2;
        frame.size.width = sizeDraw.width + 10;
    }
    
    self.autoDismissView.frame = frame;
    
    [self.autoDismissView setMsg:tips];
    
    [self.autoDismissView popoShortMsgWithSuperViewInTime:superView inTime:delayTime];
}

- (void)setAutoDismissView:(_XMCustomAlertViewAutoDismissView *)autoDismissView
{
    objc_setAssociatedObject(self, &KAutoDismissViewKey, autoDismissView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_XMCustomAlertViewAutoDismissView *)autoDismissView
{
    return objc_getAssociatedObject(self, &KAutoDismissViewKey);
}

@end
