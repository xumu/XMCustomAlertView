//
//  XMCustomAlertViewPush.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/22.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMCustomAlertView (MessagePush)

///与页面关联（页面发生跳转，弹框消失）
@property (nonatomic, assign) BOOL hugEachOtherWithPage;

- (void)xm_pushMessageWithPageIdentifier:(NSString * __nullable)identifier;
///堆栈中最先出栈的提示信息
- (void)xm_pushGlobalMessage;

///显示当前页面堆栈中的提示信息
+ (void)xm_showMessageWithPageIdentifier:(NSString *)identifier delegateObject:(id)delegate;
///销毁当前页面正显示的提示框
+ (void)xm_dismissShowingAlertViewWithPageIdentifier:(NSString *)identifier;

///显示当前页面堆栈中的提示信息
+ (void)xm_showMessageWithStackIdentifier:(NSString *)stackIdentifier;
///销毁当前页面堆栈正在显示的提示框
+ (void)xm_dismissShowingAlertViewWithStackIdentifier:(NSString *)stackIdentifier;

///重置显示控制变量
+ (void)xm_resetMessageFlag;
///是否有需要显示的提示信息
+ (BOOL)xm_hasNeedShowMessage;
///清空消息栈中所有提示信息
+ (void)xm_clearAllMessages;

@end

NS_ASSUME_NONNULL_END
