//
//  XMCustomAlertViewModelExtension.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewModelExtension.h"

@implementation XMAlertViewTitleBuilder (Extension)

- (void)copyWithOtherBuilder:(XMAlertViewTitleBuilder *)other
{
    if (other) {
        self.title = other.title;
        self.titleColor = other.titleColor;
        self.attributeTitle = other.attributeTitle;
        self.bottomEdgeInset = other.bottomEdgeInset;
    }
}

@end

@implementation XMAlertViewMessageBuilder (Extension)

- (void)copyWithOtherBuilder:(XMAlertViewMessageBuilder *)other
{
    if (other) {
        self.message = other.message;
        self.boldMessage = other.boldMessage;
        self.messageAlignment = other.messageAlignment;
        self.messageColor = other.messageColor;
        self.attributeMessage = other.attributeMessage;
        self.bottomEdgeInset = other.bottomEdgeInset;
    }
}

@end

@implementation XMAlertViewButtonBuilderExtension

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        
        if (!other && ![other isKindOfClass:[XMAlertViewButtonBuilderExtension class]]) {
            return NO;
        }
        
        XMAlertViewButtonBuilderExtension *otherObject = (XMAlertViewButtonBuilderExtension *)other;
        if (self.attributeTitle && [self.attributeTitle.string isEqualToString:otherObject.attributeTitle.string] && self.buttonIndex == otherObject.buttonIndex) {
            return YES;
        }
        
        if (self.buttonTitle && [self.buttonTitle isEqualToString:otherObject.buttonTitle] && self.buttonIndex == otherObject.buttonIndex) {
            return YES;
        }
        
        if (!self.buttonTitle && !otherObject.buttonTitle && self.buttonIndex == otherObject.buttonIndex) {
            return YES;
        }
        return NO;
    }
}

- (NSUInteger)hash
{
    if (self.attributeTitle.string) {
        return [self.buttonTitle integerValue] ^ self.buttonIndex ^ [self.attributeTitle.string integerValue];
    }
    else {
        return [self.buttonTitle integerValue] ^ self.buttonIndex;
    }
}

@end
