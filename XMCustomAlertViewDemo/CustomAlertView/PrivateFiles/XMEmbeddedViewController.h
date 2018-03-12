//
//  XMEmbeddedViewController.h
//  AMHexin
//
//  Created by fangxiaomin on 16/8/10.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMEmbeddedViewControllerDelegate <NSObject>

@property (nonatomic, assign) BOOL autoRotate;

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end

@interface XMEmbeddedViewController : UIViewController

@property (nonatomic, weak) id<XMEmbeddedViewControllerDelegate> delegate;

@end


