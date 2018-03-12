//
//  XMCustomAlertViewTool.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/19.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewTool.h"
#import "XMCustomAlertView_CustomView.h"

@implementation XMCustomAlertViewTool

+ (CGFloat)alertViewWidth
{
    return ceil([self p_widthForAlertView] * 0.747f);
}

+ (CGFloat)contentViewWidth
{
    return [self alertViewWidth] - (KLeftAndRightMargin * 2.f);
}

+ (CGFloat)maxAlertViewHeight
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return [self p_maxHeightForAlertView] - 30.f;
    }
    return [self p_maxHeightForAlertView] * 0.6f;
}

+ (CGFloat)p_maxHeightForAlertView
{
    return [self countScreenSize].height;
}


+ (CGFloat)p_widthForAlertView
{
    CGFloat width  = [self countScreenSize].width;
    CGFloat height = [self countScreenSize].height;
    return  width < height ? width : height;;
}

+ (CGSize)countScreenSize
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    return CGSizeMake(screenWidth, screenHeight);
}

+ (UIView *)customViewWithControl:(XMCustomAlertViewCustomControl *)customControl
{
    if (customControl && [customControl respondsToSelector:@selector(customView)]) {
        NSMethodSignature *signature = [customControl methodSignatureForSelector:@selector(customView)];
        if (signature) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = customControl;
            invocation.selector = @selector(customView);
            [invocation invoke];
            UIView * __unsafe_unretained customView;
            [invocation getReturnValue:&customView];
            if (customView) {
                return customView;
            }
            return nil;
        }
        return nil;
    }
    return nil;
}

@end

@implementation UIImage (XMCustomAlertView)

+ (UIImage *)xm_imageWithName:(NSString *)imageName
{
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"XMResource" ofType:@"bundle"];
    NSBundle *resourceBundle = [[NSBundle alloc] initWithPath:resourceBundlePath];
    imageName = [NSString stringWithFormat:@"%@@2x",imageName];
    NSString *imagePath = [resourceBundle pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

@end
