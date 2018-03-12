//
//  XMCustomAlertViewModel.m
//  AMHexin
//
//  Created by fangxiaomin on 17/3/8.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewModel.h"

@implementation XMAlertViewTitleBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"";
        self.titleColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        self.bottomEdgeInset = 16.f;
    }
    return self;
}
- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        
        if (!other || ![other isKindOfClass:[XMAlertViewTitleBuilder class]]) {
            return NO;
        }
        
        XMAlertViewTitleBuilder *otherObject = (XMAlertViewTitleBuilder *)other;
        
        ///先比较富文本
        if (self.attributeTitle.string && [self.attributeTitle.string isEqualToString:otherObject.attributeTitle.string]) {
            return YES;
        }
        
        ///比较标题
        if (self.title && [self.title isEqualToString:otherObject.title]) {
            return YES;
        }
        
        if (!self.title && !otherObject.title) { //都为nil默认相等
            return YES;
        }
        return NO;
    }
}

- (NSUInteger)hash
{
    if (self.attributeTitle.string) {
        return [self.title integerValue] ^ [self.attributeTitle.string integerValue];
    }
    else {
        return [self.title integerValue];
    }
}

@end


@implementation XMAlertViewMessageBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.message = @"";
        self.messageColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];;
        self.bottomEdgeInset = 0.f;
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        if (!other || ![other isKindOfClass:[XMAlertViewMessageBuilder class]]) {
            return NO;
        }
        
        XMAlertViewMessageBuilder *otherObject = (XMAlertViewMessageBuilder *)other;
        ///先比较富文本
        if (self.attributeMessage.string &&
            [self.attributeMessage.string isEqualToString:otherObject.attributeMessage.string] &&
            self.messageAlignment == otherObject.messageAlignment) {
            return YES;
        }
        
        ///比较正文内容
        if (self.message && [self.message isEqualToString:otherObject.message] && self.messageAlignment == otherObject.messageAlignment) {
            return YES;
        }
        
        if (!self.message && !otherObject.message && self.messageAlignment == otherObject.messageAlignment) {
            return YES;
        }
        
        return NO;
    }
}

- (NSUInteger)hash
{
    if (self.attributeMessage.string) {
        return [self.message integerValue] ^ self.boldMessage ^ self.messageAlignment ^ [self.attributeMessage.string integerValue];
    }
    else {
        return [self.message integerValue] ^ self.boldMessage ^ self.messageAlignment;
    }
}

@end

@implementation XMAlertViewButtonBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buttonTitle = @"";
        self.buttoncolor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];;
    }
    return self;
}

@end

@interface XMAlertViewContractModel ()

@property (nonatomic, strong) id action;

@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSUInteger index;

@end

@implementation XMAlertViewContractModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.linkable = NO;
    }
    return self;
}

- (void)setLinkable:(BOOL)linkable
{
    _linkable = linkable;
    
    if (linkable) {
        _textColor = [UIColor colorWithRed:70.0/255.0 green:145.0/255.0 blue:238.0/255.0 alpha:1.0];
    }
    else {
        _textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    }
}

+ (instancetype)contractModelWithText:(NSString *)text linkable:(BOOL)linkable action:(void (^)(XMAlertViewContractModel *))action
{
    XMAlertViewContractModel *model = [[XMAlertViewContractModel alloc] init];
    model.text = text;
    model.linkable = linkable;
    model.action = [action copy];
    return model;
}

- (id)clickAction
{
    return self.action;
}

@end

@implementation XMAlertViewContractBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contractModelArray = [NSArray array];
        self.checkable = YES;
        self.agreeImageName = @"xm_checkedbtn_icon";
        self.refuseImageName = @"xm_uncheckbtn_icon";
        self.activeLinkColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        self.bottomEdgeInset = 0.f;
    }
    return self;
}

- (void)setContractModelArray:(NSArray<XMAlertViewContractModel *> *)contractModelArray
{
    _contractModelArray = contractModelArray;
    
    NSUInteger location = 0;
    NSUInteger index = 0;
    for (XMAlertViewContractModel *contractModel in _contractModelArray) {
        NSParameterAssert(contractModel.text);
        if (contractModel.text) {
            contractModel.index = index;
            contractModel.range = NSMakeRange(location, contractModel.text.length);
            index++;
            location += contractModel.text.length;
        }
    }
}

@end

@implementation XMAlertViewSlideBuilder

- (instancetype)init
{
    if (self = [super init]) {
        self.height = 50.f;
        self.slideHeight = 40.f;
        self.edgeTop = 10.f;
        self.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:0.8];
        self.verificationColor = [UIColor colorWithRed:108.0/255.0 green:198.0/255.0 blue:84.0/255.0 alpha:1.0];
        self.slideImageName = @"xm_customAlertViewSlide";
        self.verificationSuccessImageName = @"xm_verificationSucess";
        self.backgroundTips = @"将滑块拖至最右边";
        self.verificationSuccessTips = @"验证成功";
    }
    return self;
}

@end
