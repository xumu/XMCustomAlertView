//
//  XMCustomAlertViewUniqueness.h
//  AMHexin
//
//  Created by fangxiaomin on 17/6/22.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ XMAlertViewComparator)(XMCustomAlertView *selfAlert, XMCustomAlertView *otherAlert);


@interface XMCustomAlertView (Uniqueness)

@property (nonatomic, strong) id uniqueIdentifier;

- (void)uniquenessJudgeWithComparator:(XMAlertViewComparator)cmptr;

@end

NS_ASSUME_NONNULL_END
