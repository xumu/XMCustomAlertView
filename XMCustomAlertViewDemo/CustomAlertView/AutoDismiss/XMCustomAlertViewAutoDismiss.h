//
//  XMCustomAlertViewAutoDismiss.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/23.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertView.h"

@interface XMCustomAlertView (AutoDismiss)

/**
 * 显示在指定视图上
 *
 @param superView 父视图
 */
- (void)showInSuperView:(UIView * __nonnull)superView;

- (void)showAutoDismissTips:(NSString * __nonnull)tips;
- (void)showAutoDismissTips:(NSString * __nonnull)tips delayTime:(NSTimeInterval)delayTime;

@end
