//
//  XMEmbeddedViewController.m
//  AMHexin
//
//  Created by fangxiaomin on 16/8/10.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import "XMEmbeddedViewController.h"

@interface XMEmbeddedViewController ()

@end

@implementation XMEmbeddedViewController

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self.delegate dismissViewControllerAnimated:flag completion:completion];
}

- (BOOL)shouldAutorotate
{
    return self.delegate.autoRotate;
}

@end
