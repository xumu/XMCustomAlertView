//
//  XMCustomAlertViewModel.h
//  AMHexin
//
//  Created by fangxiaomin on 17/3/8.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMAlertViewTitleBuilder : NSObject

/* 标题内容 */
@property (nonatomic, copy) NSString *title;
/* 标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/* 自定义标题 */
@property (nonatomic, copy) NSAttributedString *attributeTitle;
/*底部边距*/
@property (nonatomic, assign) CGFloat bottomEdgeInset;

@end

@interface XMAlertViewMessageBuilder : NSObject

/* 正文内容 */
@property (nonatomic, copy) NSString *message;
/* 正文内容加粗 */
@property (nonatomic, assign) BOOL boldMessage;
/* 正文内容对齐方式 */
@property (nonatomic, assign) NSTextAlignment messageAlignment;
/* 正文内容颜色 */
@property (nonatomic, strong) UIColor *messageColor;
/* 自定义正文 */
@property (nonatomic, copy) NSAttributedString *attributeMessage;
/*底部边距*/
@property (nonatomic, assign) CGFloat bottomEdgeInset;

@end

@interface XMAlertViewButtonBuilder : NSObject

/* 按钮标题 */
@property (nonatomic, copy) NSString *buttonTitle;
/* 按钮标题加粗 */
@property (nonatomic, assign) BOOL boldButton;
/* 按钮标题颜色 */
@property (nonatomic, strong) UIColor *buttoncolor;
/* 日间自定义按钮标题 */
@property (nonatomic, copy) NSAttributedString *attributeTitle;

@end

@interface XMAlertViewContractModel : NSObject

/*内容*/
@property (nonatomic, copy) NSString *text;
/*是否可点击*/
@property (nonatomic, assign) BOOL linkable; //缺省值：NO
/*日间颜色*/
@property (nonatomic, strong) UIColor *textColor;

+ (instancetype)contractModelWithText:(NSString *)text linkable:(BOOL)linkable action:(void(^)(XMAlertViewContractModel *contractModel))action;

@end

@interface XMAlertViewContractBuilder : NSObject

@property (nonatomic, strong) NSArray<XMAlertViewContractModel *> *contractModelArray;

/*是否可以拒绝合同*/
@property (nonatomic, assign) BOOL checkable;

/*同意Image*/
@property (nonatomic, copy) NSString *agreeImageName;
/*拒绝Image*/
@property (nonatomic, copy) NSString *refuseImageName;
/*激活链接颜色*/
@property (nonatomic, strong) UIColor *activeLinkColor;
/*底部边距*/
@property (nonatomic, assign) CGFloat bottomEdgeInset;

@end

@interface XMAlertViewSlideBuilder : NSObject

/*滑块控件高度*/
@property (nonatomic, assign) CGFloat height; //缺省值50
/*可滑动区域高度*/
@property (nonatomic, assign) CGFloat slideHeight; //缺省值40
/*可滑动区域四周EdgeInset*/
@property (nonatomic, assign) CGFloat edgeTop; //缺省值 10

/*可滑动区域背景颜色*/
@property (nonatomic, strong) UIColor *backgroundColor; //缺省值 0xeeeeee
/*验证颜色*/
@property (nonatomic, strong) UIColor *verificationColor; //缺省值 0x6cc654
/*滑块图片名称*/
@property (nonatomic, copy) NSString *slideImageName;
/*验证成功图片名称*/
@property (nonatomic, copy) NSString *verificationSuccessImageName;

/*提示滑动验证语*/
@property (nonatomic, copy) NSString *backgroundTips; //缺省值 “将滑块拖至最右边”
/*验证成功提示语*/
@property (nonatomic, copy) NSString *verificationSuccessTips; //缺省值 “验证成功”

@end
