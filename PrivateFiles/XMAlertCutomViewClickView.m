//
//  XMAlertCutomViewClickView.m
//  AMHexin
//
//  Created by fangxiaomin on 16/10/27.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import "XMAlertCutomViewClickView.h"

#define CONTENTVIEWTAG 10225

@implementation XMAlertCutomViewClickView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = [super pointInside:point withEvent:event];
    if (!result) {
        UIView *contentView = [self viewWithTag:CONTENTVIEWTAG];
        if (contentView) {
            CGPoint temPoint = [contentView convertPoint:point fromView:self];
            if ([contentView pointInside:temPoint withEvent:event]) {
                result = YES;
            }
        }
    }
    return result;
}

@end
