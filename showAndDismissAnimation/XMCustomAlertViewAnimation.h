//
//  XMCustomAlertViewAnimation.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///动画工厂
@protocol XMCustomAlertViewAnimationFactory <NSObject>
/**
 自定义弹框出现动画

 @return 开场动画
 */
- (CAPropertyAnimation *)showAnimation;

/**
 自定义弹框消失动画

 @return 退场动画
 */
- (CAPropertyAnimation *)dismissAnimation;

@end

///弹簧动画抽象基类
@interface XMAlertViewSpringAnimationFactory : NSObject <XMCustomAlertViewAnimationFactory>

@property (readwrite, nonatomic, assign) CGFloat damping;
@property (readwrite, nonatomic, assign) CGFloat mass;
@property (readwrite, nonatomic, assign) CGFloat stiffness;
@property (readwrite, nonatomic, assign) CGFloat velocity;
@property CFTimeInterval duration;

- (CAPropertyAnimation *)springAnimationForKeyPath:(NSString *)keyPath;

@end

///系统动画
@interface XMAlertViewSystemAnimationFactory : XMAlertViewSpringAnimationFactory

@end

///淡入淡出动画
@interface XMAlertViewOpacityAnimationFactory : XMAlertViewSpringAnimationFactory

@end

///右->左动画
@interface XMAlertViewRightToLeftAnimationFactory : XMAlertViewSpringAnimationFactory

@end

///下->上动画
@interface XMAlertViewDownToUpAnimationFactory : XMAlertViewSpringAnimationFactory

@end

NS_ASSUME_NONNULL_END
