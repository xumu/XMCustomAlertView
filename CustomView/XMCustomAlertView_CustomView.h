//
//  XMCustomAlertView_CustomView.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/19.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AlertCustomViewModifyHandler)(__kindof UIView *customView);

/**
 弹框自定义控件修改样式协议，可以不遵循
 */
@protocol XMCustomAlertViewCustomViewChangePtotocol <NSObject>

@optional
/**
 改变自定义控件默认样式，增加自定义控件灵活性

 @param modifyHandler 修改自定义控件样式句柄
 @return 修改动作是否执行
 */
- (BOOL)changeCustomViewWithModifyHandler:(AlertCustomViewModifyHandler)modifyHandler;

@end

///自定义组件父类
@interface XMCustomAlertViewCustomControl : NSObject

@end

@class XMCustomAlertViewCustomCloseBtn;
typedef void(^ __nullable closeAction)(XMCustomAlertViewCustomCloseBtn *closeBtn);

///自定义关闭按钮挂件
@interface XMCustomAlertViewCustomCloseBtn : XMCustomAlertViewCustomControl <XMCustomAlertViewCustomViewChangePtotocol>

+ (instancetype)initCustomCloseBtnWithClickAction:(closeAction)closeAction;
- (instancetype)initCustomCloseBtnWithClickAction:(closeAction)closeAction;

@end

///自定义标题
@interface XMCustomAlertViewCustomTitle : XMCustomAlertViewCustomControl <XMCustomAlertViewCustomViewChangePtotocol>

+ (instancetype)customTitleWithConfigurationHandler:(void(^ __nullable)(XMAlertViewTitleBuilder *titleBuilder))configurationHandler;
- (instancetype)initCustomTitleWithConfigurationHandler:(void(^ __nullable)(XMAlertViewTitleBuilder *titleBuilder))configurationHandler NS_DESIGNATED_INITIALIZER;

@end

///自定义正文
@interface XMCustomAlertViewCustomMessage : XMCustomAlertViewCustomControl <XMCustomAlertViewCustomViewChangePtotocol>

+ (instancetype)customMessageWithConfigurationHandler:(void(^ __nullable)(XMAlertViewMessageBuilder *messageBuilder))configurationHandler;
- (instancetype)initCustomMessageWithConfigurationHandler:(void(^ __nullable)(XMAlertViewMessageBuilder *messageBuilder))configurationHandler NS_DESIGNATED_INITIALIZER;

@end

@class XMCustomAlertViewAction;
typedef void(^ __nullable clickAction)(XMCustomAlertViewAction *action);

///自定义按钮(特殊控件)
@interface XMCustomAlertViewAction : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *attributeTitle;
@property (nonatomic, assign, readonly) BOOL isBold;

+ (instancetype)actionWithConfigurationHandler:(void(^ __nullable)(XMAlertViewButtonBuilder *buttonBuilder))configurationHandler clickHander:(clickAction)clickHandler;
- (instancetype)initActionWithConfigurationHandler:(void(^ __nullable)(XMAlertViewButtonBuilder *buttonBuilder))configurationHandler clickHander:(clickAction)clickHandler NS_DESIGNATED_INITIALIZER;

- (BOOL)changeActionWithChangeHandler:(void(^)(XMAlertViewButtonBuilder *buttonBuilder))changeHandler;

@end


typedef void(^ __nullable checkboxAction)(BOOL agreeContract);

///自定义合同控件
@interface XMCustomAlertViewCustomContract : XMCustomAlertViewCustomControl <XMCustomAlertViewCustomViewChangePtotocol>

@property (nonatomic, assign, readonly) BOOL agreeContract;

+ (instancetype)contractWithConfigurationHandler:(void(^ __nullable)(XMAlertViewContractBuilder *contractBuilder))configurationHandler  checkboxAction:(checkboxAction)checkboxAction;
- (instancetype)initContractWithConfigurationHandler:(void(^ __nullable)(XMAlertViewContractBuilder *contractBuilder))configurationHandler checkboxAction:(checkboxAction)checkboxAction NS_DESIGNATED_INITIALIZER;

@end

@class XMCustomAlertViewSlideController;
typedef void(^ __nullable verificationSuccessfulAction)(XMCustomAlertViewSlideController *slideController);

///自定义滑动控件
@interface XMCustomAlertViewSlideController : XMCustomAlertViewCustomControl

+ (instancetype)initSlideWithConfigurationHandler:(void(^ __nullable)(XMAlertViewSlideBuilder *slideBuilder))configurationHandler verificationSuccessfulAction:(verificationSuccessfulAction)verificationSuccessfulAction;
- (instancetype)initSlideWithConfigurationHandler:(void(^ __nullable)(XMAlertViewSlideBuilder *slideBuilder))configurationHandler verificationSuccessfulAction:(verificationSuccessfulAction)verificationSuccessfulAction NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
