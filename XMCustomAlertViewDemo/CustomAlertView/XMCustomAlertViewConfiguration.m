//
//  XMCustomAlertViewConfiguration.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewConfiguration.h"
#import "XMCustomAlertViewTool.h"
#import "XMCustomAlertViewAnimation.h"

@implementation XMAlertViewConfigurationContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = [XMCustomAlertViewTool alertViewWidth];
        self.contentInset = UIEdgeInsetsMake(KTopMargin, KLeftAndRightMargin, KBottomMargin, KLeftAndRightMargin);
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        self.closeBtnSwitch = NO;
        self.hasPanel = YES;
        self.scrollable = YES;
        self.panelColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
        self.panelCornerRadius = KCornerRadius;
        self.showAnimation = [[[XMAlertViewSystemAnimationFactory alloc] init] showAnimation];
        self.dismissAnimation = [[[XMAlertViewSystemAnimationFactory alloc] init] dismissAnimation];
    }
    return self;
}

@end
