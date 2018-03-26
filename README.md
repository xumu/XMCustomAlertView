## 简介
在iOS项目迭代过程中我们经常会增加新的功能，然后还需要有新功能引导。实际情况是我们常常会看见系统的UIAlertView覆盖在引导页面上，给用户体验增加一层蒙阴。更极端的情况是产品常常希望弹框还需要分优先级依次弹出，或者弹框只能在特定页面出现。于是就有了XMCustomAlertView的诞生。
## 功能
- [x] UIAlertView功能
- [x] 优先级
- [x] 有效期
- [x] 界面自由组合
- [x] 自定义动画效果
- [x] 带有页面属性的AlertView
## 依赖的环境
- iOS 7.0 +
- CAAnimationBlocks 0.0.1
- RBBAnimation 0.3.0
- TTTAttributedLabel 2.0.0
## 使用方法
0. 头文件

```objective-c
#import "XMCustomAlertView_Define.h"
```

1. 便利方法 

```objective-c
//代理模式
XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
[alertView show];
//代码块模式
XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] clickHandler:^(XMCustomAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        NSLog(@"弹框被点击");
}];
[alertView show];
```

![便利方法](https://upload-images.jianshu.io/upload_images/1776603-efe3bad3db2007b4.gif?imageMogr2/auto-orient/strip)

2. 修改标题、内容、按钮
```objective-c
XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"自定义弹框" message:@"我是一个通过便利方法生成的自定义弹框控件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
[alertView setTitle:@"修改标题"];
[alertView setMessage:@"修改自定义弹框内容"];
[alertView setButtonInfoWithIndex:1 blcok:^(XMAlertViewButtonBuilder * _Nonnull buttonBuilder) {
    buttonBuilder.buttoncolor = [UIColor redColor];
}];
[alertView show];
```
![修改弹框内容](https://upload-images.jianshu.io/upload_images/1776603-1f2da203b716a62e.gif?imageMogr2/auto-orient/strip)

3. UI界面自由组合
- UI界面自由组合需要界面控件库的支持，目前库中有标题、正文、按钮、合同、滑动块控件
```objective-c
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
```
![界面元素自由组合](https://upload-images.jianshu.io/upload_images/1776603-6abb427ff63ab90c.gif?imageMogr2/auto-orient/strip)

4. 自定义动画效果
- 目前可以自动弹框入场和出场动画，库中有淡入淡出、左右飞入飞出、上下飞入飞出。当然，有兴趣可以自己扩展
```objective-c
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
```
![自定义弹框动画](https://upload-images.jianshu.io/upload_images/1776603-45f74c96dec27f70.gif?imageMogr2/auto-orient/strip)

5. 具有页面属性的弹框
- 这种弹框只能在指定的页面弹出，必要时会跟着页面的消失而消失
```objective-c
///在页面显示时调用
[XMCustomAlertView xm_showMessageWithPageIdentifier:@"pageIdentifier" delegateObject:self];
///在页面即将消失时调用
[XMCustomAlertView xm_dismissShowingAlertViewWithPageIdentifier:@"pageIdentifier"];
///其他页面可以设置"pageIdentifier"页面属性的弹框
XMCustomAlertView *alertView = [[XMCustomAlertView alloc] initWithTitle:@"页面弹框" message:@"这是个只能在指定页面弹出的弹框" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
[alertView xm_pushMessageWithPageIdentifier:@"pageIdentifier"];
```
6. 其他
- 指定弹框的父视图
```objective-c
[alertView showInSuperView:viewA];
```
- 弹框上显示Toast提示
```objective-c
[alertView showAutoDismissTips:@"Toast提示" delayTime:0.5f];
```
- 弹框可以设置是否跟着屏幕一起旋转
```objective-c
alertView.autoRotate = YES;
```
- 当然你也可以完全定制你私人的UI界面
```objective-c
[alertView addCustomViewWithView:CustomView];
```
- 还有一些唯一性判断逻辑，此处不再赘述。
## 作者
- [主页](https://www.jianshu.com/u/0bf8dc16b794)
- [邮箱](fang.x.m@qq.com)
