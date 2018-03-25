//
//  ViewController.m
//  XMCustomAlertViewDemo
//
//  Created by F_knight on 2018/3/11.
//  Copyright © 2018年 F_knight. All rights reserved.
//

#import "ViewController.h"
#import "XMCustomAlertView_Define.h"
#import "XMCustomAlertViewAutoDismiss.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self ConvenienceMethod];
}

- (void)ConvenienceMethod
{
    XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)ConvenienceMethod2
{
    XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] clickHandler:^(XMCustomAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        NSLog(@"弹框被点击");
    }];
    [alertView show];
}

- (void)modifyAlertViewInfo
{
    XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setTitle:@"修改标题"];
    [alertView setMessage:@"修改自定义弹框内容"];
    [alertView setButtonInfoWithIndex:1 blcok:^(XMAlertViewButtonBuilder * _Nonnull buttonBuilder) {
        buttonBuilder.buttoncolor = [UIColor redColor];
    }];
    [alertView show];
}

- (void)CombinationUIControl
{
    XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithConfigurationHandler:nil];
    XMCustomAlertViewCustomTitle *customtTitle = [XMCustomAlertViewCustomTitle customTitleWithConfigurationHandler:^(XMAlertViewTitleBuilder * _Nonnull titleBuilder) {
        titleBuilder.title = @"合同项目";
        titleBuilder.titleColor = [UIColor redColor];
    }];
    XMCustomAlertViewCustomMessage *customMessage = [XMCustomAlertViewCustomMessage customMessageWithConfigurationHandler:^(XMAlertViewMessageBuilder * _Nonnull messageBuilder) {
        messageBuilder.message = @"一部法律根据《立法法》第六十一条的规定，一般由编、章、节、条、款、项、目组成。编、章、节是对法条的归类。所以，在使用法律时只需引用到条、款、项、目即可，无需指出该条所在的编、章、节。";
    }];
    XMCustomAlertViewCustomContract *customContract = [XMCustomAlertViewCustomContract contractWithConfigurationHandler:^(XMAlertViewContractBuilder * _Nonnull contractBuilder) {
        XMAlertViewContractModel *contractModel1 = [XMAlertViewContractModel contractModelWithText:@"勾选及代表您同意" linkable:NO action:nil];
        XMAlertViewContractModel *contractModel2 = [XMAlertViewContractModel contractModelWithText:@"《立法法》" linkable:YES action:^(XMAlertViewContractModel *contractModel) {
            NSLog(@"条款被点击");
        }];
        XMAlertViewContractModel *contractModel3 = [XMAlertViewContractModel contractModelWithText:@"相关条款" linkable:NO action:nil];
        
        contractBuilder.contractModelArray = @[contractModel1, contractModel2, contractModel3];
        contractBuilder.checkable = YES;
    } checkboxAction:^(BOOL agreeContract) {
        NSLog(@"同意/拒绝合同");
    }];
    XMCustomAlertViewAction *action = [XMCustomAlertViewAction actionWithConfigurationHandler:^(XMAlertViewButtonBuilder * _Nonnull buttonBuilder) {
        buttonBuilder.buttonTitle = @"取消";
    } clickHander:^(XMCustomAlertViewAction * _Nonnull action) {
        NSLog(@"取消按钮被点击");
    }];
    [alertView addCustomViewWithControl:customtTitle];
    [alertView addCustomViewWithControl:customMessage];
    [alertView addCustomViewWithControl:customContract];
    [alertView addAction:action];
    [alertView show];
}

- (void)customShowAndDismissAnimation
{
    XMCustomAlertView *alertView1 = [[XMCustomAlertView alloc] initWithTitle:@"动画" message:@"我是个实现了系统动画的弹框，可以淡入淡出" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView1 modifyConfigurationContextWithHandler:^(XMAlertViewConfigurationContext * _Nonnull configurationContext) {
        configurationContext.showAnimation = [[XMAlertViewSystemAnimationFactory new] showAnimation];
        configurationContext.dismissAnimation = [[XMAlertViewSystemAnimationFactory new] dismissAnimation];
    }];
    [alertView1 show];
    XMCustomAlertView *alertView2 = [[XMCustomAlertView alloc] initWithTitle:@"动画" message:@"我是个从右->左出现，从左->右消失的弹框" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView2 modifyConfigurationContextWithHandler:^(XMAlertViewConfigurationContext * _Nonnull configurationContext) {
        configurationContext.showAnimation = [[XMAlertViewRightToLeftAnimationFactory new] showAnimation];
        configurationContext.dismissAnimation = [[XMAlertViewRightToLeftAnimationFactory new] dismissAnimation];
    }];
    [alertView2 show];
    XMCustomAlertView *alertView3 = [[XMCustomAlertView alloc] initWithTitle:@"动画" message:@"我是个从下->上出现，从上->下消失的弹框" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView3 modifyConfigurationContextWithHandler:^(XMAlertViewConfigurationContext * _Nonnull configurationContext) {
        configurationContext.showAnimation = [[XMAlertViewDownToUpAnimationFactory new] showAnimation];
        configurationContext.dismissAnimation = [[XMAlertViewDownToUpAnimationFactory new] dismissAnimation];
    }];
    [alertView3 show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self ConvenienceMethod];
}


@end
