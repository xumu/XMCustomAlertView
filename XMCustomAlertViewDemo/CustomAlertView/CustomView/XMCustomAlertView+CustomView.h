//
//  XMCustomAlertView+CustomView.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/19.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@class XMAlertViewConfigurationContext, XMCustomAlertViewCustomControl, XMCustomAlertViewAction;

///提示框自定义视图
@interface XMCustomAlertView (CustomView)

/**
 自定义控件，初始化方法

 @param configurationHandler 初始化配置文件
 @return 自定义弹框
 */
- (instancetype)initWithConfigurationHandler:(void(^ __nullable)(XMAlertViewConfigurationContext *configurationContext))configurationHandler;

- (BOOL)modifyConfigurationContextWithHandler:(void(^)(XMAlertViewConfigurationContext *configurationContext))modifyHandler;

- (BOOL)changeTitleWithModifyHandler:(void(^)(UILabel *titleLable))modifyHandler;

- (BOOL)changeMessageWithModifyHandler:(void(^)(UILabel *messageLabel))modifyHandler;

- (BOOL)addCustomViewWithControl:(XMCustomAlertViewCustomControl *)customControl;

- (BOOL)addCustomViewWithView:(UIView *)customView;

- (BOOL)addAction:(XMCustomAlertViewAction *)action;

@end

NS_ASSUME_NONNULL_END
