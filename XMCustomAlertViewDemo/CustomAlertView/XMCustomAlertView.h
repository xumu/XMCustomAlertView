//
//  XMCustomAlertView.h
//  AMHexin
//
//  Created by fangxiaomin on 16/8/8.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XMCustomAlertViewDelegate;
@class XMCustomAlertView;

typedef NS_ENUM(NSInteger, XMCustomAlertViewPriority) {
    XMCustomAlertViewPriority_Height = 2,
    XMCustomAlertViewPriority_Default = 0,
    XMCustomAlertViewPriority_Low = -2,
};

typedef void(^ onButtonTouchUpInside)(XMCustomAlertView *alertView, NSInteger buttonIndex);
typedef void(^ willPresentAlertView)(XMCustomAlertView *alertView);
typedef void(^ didPresentAlertView)(XMCustomAlertView *alertView);
typedef void(^ willDismissAlertView)(XMCustomAlertView *alertView, NSInteger buttonIndex);
typedef void(^ didDismissAlertView)(XMCustomAlertView *alertView, NSInteger buttonIndex);
typedef BOOL(^ alertViewIsEffective)(void);

@class XMAlertViewTitleBuilder, XMAlertViewMessageBuilder, XMAlertViewButtonBuilder;

@interface XMCustomAlertView : UIView

@property (nonatomic, assign) XMCustomAlertViewPriority priority;  //优先级

@property (nonatomic, copy, nullable) NSString *title; //标题
@property (nonatomic, copy, nullable) NSString *message; //tips

@property (nonatomic, assign) NSInteger cancelButtonIndex;
@property (nonatomic, assign, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, assign, readonly) NSInteger numberOfButtons;
@property (nonatomic, assign, readonly, getter=isVisible) NSInteger visible;

@property (nonatomic, assign) BOOL autoRotate; // NO:不支持旋转  YES:支持旋转

@property (nonatomic, weak, nullable) id<XMCustomAlertViewDelegate> delegate;

//回调Block,既设置了代理又实现了Block优先响应Block
@property (nonatomic, copy, nullable) onButtonTouchUpInside clickHandler;
@property (nonatomic, copy, nullable) willPresentAlertView  willPresentHandler;
@property (nonatomic, copy, nullable) didPresentAlertView   didPresentHandler;
@property (nonatomic, copy, nullable) willDismissAlertView  willDismissHandler;
@property (nonatomic, copy, nullable) didDismissAlertView   didDismissHandler;

//判断提示框是否在有效期的Block
@property (nonatomic, copy, nullable) alertViewIsEffective judgeEffectiveBlock;

///快速初始化方法
- (instancetype)initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(nullable id)delegate
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

///快速初始化方法，用Block处理回调逻辑
- (instancetype)initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(nullable id)delegate
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSArray<NSString *> *)otherButtonTitles
                 clickHandler:(nullable onButtonTouchUpInside)handler;

- (void)setTitleInfoWithBlock:(void(^)(XMAlertViewTitleBuilder *titleBuilder))titleInfoBlock;
- (void)setMessageInfoWithBlock:(void(^)(XMAlertViewMessageBuilder *messageBuilder))messageInfoBlock;
- (void)setButtonInfoWithIndex:(NSInteger)buttonIndex blcok:(void(^)(XMAlertViewButtonBuilder *buttonBuilder))buttonInfoBlock;
- (NSInteger)addButtonWithBlock:(void(^)(XMAlertViewButtonBuilder *buttonBuilder))buttonInfoBlock;

- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

///显示在内部window上
- (void)show;
///撤销弹框
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
///销毁正在显示的提示框
+ (void)destroyShowingAlertViewWithAnimated:(BOOL)animated;

@end


@protocol XMCustomAlertViewDelegate <NSObject>
@optional

- (void)alertView:(XMCustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)willPresentAlertView:(XMCustomAlertView *)alertView;
- (void)didPresentAlertView:(XMCustomAlertView *)alertView;

- (void)alertView:(XMCustomAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(XMCustomAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end

NS_ASSUME_NONNULL_END
