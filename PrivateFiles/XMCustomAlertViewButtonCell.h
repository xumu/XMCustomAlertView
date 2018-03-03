//
//  XMCustomAlertViewButtonCell.h
//  AMHexin
//
//  Created by fangxiaomin on 16/8/9.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMCustomAlertView_CustomView.h"

@class XMAlertViewButtonBuilderExtension;

@interface XMCustomAlertViewAction (ConfigurationContext)

- (XMAlertViewButtonBuilderExtension *)configurationContext;

@end

@interface XMCustomAlertViewButtonCell : UITableViewCell

@property (nonatomic, assign, readonly) NSInteger buttonIndex;
@property (nonatomic, assign) BOOL isLastRow;
@property (nonatomic, strong) XMCustomAlertViewAction *action;

@end
