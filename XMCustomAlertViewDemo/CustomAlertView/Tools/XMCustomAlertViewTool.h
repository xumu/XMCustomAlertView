//
//  XMCustomAlertViewTool.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/19.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CANCELTABLETAG 10223
#define OTHERTABLETAG  10224
#define CONTENTVIEWTAG 10225

static const CGFloat    KLeftAndRightMargin = 24.f;
static const CGFloat    KTopMargin = 24.f;
static const CGFloat    KBottomMargin = 20.f;
static const CGFloat    KButtonHeight = 44.f;
static const CGFloat    KCornerRadius = 9.f;
static const CGFloat    KLineSpacing = 6.f;

@class XMCustomAlertViewCustomControl;

@interface XMCustomAlertViewTool : NSObject

+ (CGFloat)alertViewWidth;
+ (CGFloat)contentViewWidth;
+ (CGSize)countScreenSize;
+ (CGFloat)maxAlertViewHeight;
+ (UIView *)customViewWithControl:(XMCustomAlertViewCustomControl *)customControl;

@end

@interface UIImage (XMCustomAlertView)

+ (UIImage *)xm_imageWithName:(NSString *)imageName;

@end
