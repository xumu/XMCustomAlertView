//
//  XMCustomAlertViewAnimation.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewAnimation.h"

#define Screen_width (MIN([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
#define Screen_height (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))

#ifdef USE_PRIVATE_SPRING_ANIMATION_CLASS
#define kSpringAnimationClassName CASpringAnimation

@interface CASpringAnimation : CABasicAnimation
- (float)damping;
- (double)durationForEpsilon:(double)arg1;
- (float)mass;
- (void)setDamping:(float)arg1;
- (void)setMass:(float)arg1;
- (void)setStiffness:(float)arg1;
- (void)setVelocity:(float)arg1;
- (float)stiffness;
- (float)velocity;
@end
#else
#import "RBBSpringAnimation.h"
#define kSpringAnimationClassName RBBSpringAnimation
#endif


@implementation XMAlertViewSpringAnimationFactory

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.velocity = 0.f;
        self.mass = 3.f;
        self.stiffness = 1000.f;
        self.damping = 500.f;
        self.duration = 0.5058237314224243f;
    }
    return self;
}

- (kSpringAnimationClassName *)springAnimationForKeyPath:(NSString *)keyPath
{
    kSpringAnimationClassName *animation = [[kSpringAnimationClassName alloc] init];
    
    animation.keyPath = keyPath;
    animation.velocity = self.velocity;
    animation.mass = self.mass;
    animation.stiffness = self.stiffness;
    animation.damping = self.damping;
    animation.duration = self.duration;
    
    return animation;
}

- (CAPropertyAnimation *)propertyAnimationWith:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue
{
    ///创建动画
    kSpringAnimationClassName *propertyAnimation = (kSpringAnimationClassName *)[self springAnimationForKeyPath:keyPath];
    propertyAnimation.fromValue = fromValue;
    // CASpringAnimation has all toValues as nil, but RBBSpringAnimation doesn't support it
    propertyAnimation.toValue = toValue;
    propertyAnimation.removedOnCompletion = NO;
    propertyAnimation.fillMode = kCAFillModeForwards;
    return propertyAnimation;
}

///子类实现
- (CAPropertyAnimation *)showAnimation
{
    return nil;
}

///子类实现
- (CAPropertyAnimation *)dismissAnimation
{
    return nil;
}

@end


@implementation XMAlertViewSystemAnimationFactory

- (CAPropertyAnimation *)showAnimation
{
    CATransform3D transformFrom = CATransform3DMakeScale(1.26, 1.26, 1.0);
    CATransform3D transformTo = CATransform3DMakeScale(1.0, 1.0, 1.0);
    id fromValue = [NSValue valueWithCATransform3D:transformFrom];
    id toValue = [NSValue valueWithCATransform3D:transformTo];
    return [self propertyAnimationWith:@"transform" fromValue:fromValue toValue:toValue];
}

- (CAPropertyAnimation *)dismissAnimation
{
    CATransform3D transformFrom = CATransform3DMakeScale(1.0, 1.0, 1.0);
    CATransform3D transformTo = CATransform3DMakeScale(0.840, 0.840, 1.0);
    id fromValue = [NSValue valueWithCATransform3D:transformFrom];
    id toValue = [NSValue valueWithCATransform3D:transformTo];
    return [self propertyAnimationWith:@"transform" fromValue:fromValue toValue:toValue];
}

@end


@implementation XMAlertViewOpacityAnimationFactory

- (CAPropertyAnimation *)showAnimation
{
    return [self propertyAnimationWith:@"opacity" fromValue:@0.f toValue:@1.f];
}

- (CAPropertyAnimation *)dismissAnimation
{
    return [self propertyAnimationWith:@"opacity" fromValue:@1.f toValue:@0.f];
}

@end


@implementation XMAlertViewRightToLeftAnimationFactory

- (CAPropertyAnimation *)showAnimation
{
    CGPoint fromPoint = CGPointMake(Screen_width * 3 / 2, Screen_height / 2);
    CGPoint toPoint = CGPointMake(Screen_width / 2, Screen_height / 2);
    id fromValue = [NSValue valueWithCGPoint:fromPoint];
    id toValue = [NSValue valueWithCGPoint:toPoint];
    return [self propertyAnimationWith:@"position" fromValue:fromValue toValue:toValue];
}

- (CAPropertyAnimation *)dismissAnimation
{
    CGPoint fromPoint = CGPointMake(Screen_width / 2, Screen_height / 2);
    CGPoint toPoint = CGPointMake(Screen_width * 3 / 2, Screen_height / 2);
    id fromValue = [NSValue valueWithCGPoint:fromPoint];
    id toValue = [NSValue valueWithCGPoint:toPoint];
    return [self propertyAnimationWith:@"position" fromValue:fromValue toValue:toValue];
}

@end


@implementation XMAlertViewDownToUpAnimationFactory

- (CAPropertyAnimation *)showAnimation
{
    CGPoint fromPoint = CGPointMake(Screen_width / 2, Screen_height * 3 / 2);
    CGPoint toPoint = CGPointMake(Screen_width / 2, Screen_height / 2);
    id fromValue = [NSValue valueWithCGPoint:fromPoint];
    id toValue = [NSValue valueWithCGPoint:toPoint];
    return [self propertyAnimationWith:@"position" fromValue:fromValue toValue:toValue];
}

- (CAPropertyAnimation *)dismissAnimation
{
    CGPoint fromPoint = CGPointMake(Screen_width / 2, Screen_height / 2);
    CGPoint toPoint = CGPointMake(Screen_width / 2, Screen_height * 3 / 2);
    id fromValue = [NSValue valueWithCGPoint:fromPoint];
    id toValue = [NSValue valueWithCGPoint:toPoint];
    return [self propertyAnimationWith:@"position" fromValue:fromValue toValue:toValue];
}

@end
