//
//  XMCustomAlertViewModelExtension.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/20.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMCustomAlertViewModel.h"

@interface XMAlertViewTitleBuilder(Extension)

- (void)copyWithOtherBuilder:(XMAlertViewTitleBuilder *)other;

@end

@interface XMAlertViewMessageBuilder(Extension)

- (void)copyWithOtherBuilder:(XMAlertViewMessageBuilder *)other;

@end

@interface XMAlertViewButtonBuilderExtension : XMAlertViewButtonBuilder

@property (nonatomic, assign) NSInteger buttonIndex;
@property (nonatomic, assign) BOOL isLastRow;
/*来自快速初始化方法*/
@property (nonatomic, assign) BOOL fromConvenient;
@property (nonatomic, copy) id clickActionBlock;

@end

typedef void(^XMContractModelAction)(XMAlertViewContractModel *contractModel);

@interface XMAlertViewContractModel (Action)

@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSUInteger index;

- (XMContractModelAction)clickAction;

@end
