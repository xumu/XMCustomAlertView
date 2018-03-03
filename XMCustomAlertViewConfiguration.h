//
//  XMCustomAlertViewConfiguration.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ closeBtnAction)(void);

@interface XMAlertViewConfigurationContext : NSObject

/*弹框宽度*/
@property (nonatomic, assign) CGFloat width; //缺省值：@2x 280.f、@3x 1.5 * 280.f;
/*弹框四周EdgeInset*/
@property (nonatomic, assign) UIEdgeInsets contentInset; //缺省值：{25,0,20,0} 内部只响应Top和bottom
/*遮罩背景颜色*/
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
/*左上角关闭按钮开关*/
@property (nonatomic, assign) BOOL closeBtnSwitch; //缺省值：NO
/*左上角关闭按钮开关Action*/
@property (nonatomic, copy, nullable) closeBtnAction closeBtnAction;

/*是否需要背景面板*/
@property (nonatomic, assign) BOOL hasPanel; //缺省值：YES
/*当弹框高度超出屏幕高度的60%时，是否需要滚动效果*/
@property (nonatomic, assign) BOOL scrollable; //缺省值：YES
/*面板日间颜色*/
@property (nonatomic, strong, nullable) UIColor *panelColor;
/*面板圆角弧度*/
@property (nonatomic, assign) CGFloat panelCornerRadius; //缺省值：9

/*出场动画*/
@property (nonatomic, strong, nullable) CAPropertyAnimation *showAnimation;
/*离场动画*/
@property (nonatomic, strong, nullable) CAPropertyAnimation *dismissAnimation;

@end
