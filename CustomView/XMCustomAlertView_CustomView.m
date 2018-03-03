//
//  XMCustomAlertView_CustomView.m
//  AMHexin
//
//  Created by fangxiaomin on 17/6/19.
//  Copyright © 2017年 Hexin. All rights reserved.
//

#import "XMCustomAlertView_CustomView.h"
#import "XMCustomAlertView.h"
#import "XMCustomAlertViewTool.h"
#import "XMCustomAlertViewModelExtension.h"
#import "TTTAttributedLabel.h"


static const CGFloat KCustomViewTextFontSize18 = 18.f;
static const CGFloat KCustomViewTextFontSize15 = 15.f;

/**
 自定义弹框控件协议
 */
@protocol XMCustomAlertViewCustomViewPtotocol <NSObject>

- (UIView * __nullable)customView;

@end


@interface XMCustomAlertViewCustomControl() <XMCustomAlertViewCustomViewPtotocol>

@end

@implementation XMCustomAlertViewCustomControl

///子类实现，只有实现控件协议并且返回不为nil才会将自定义控件添加到AlertView上
- (UIView *)customView
{
    return nil;
}

@end
///================================================  类分割线  ========================================///


@interface CustomBackgroundView : UIView

@end

@implementation CustomBackgroundView

@end


@interface XMCustomAlertViewCustomCloseBtn ()

@property (nonatomic, copy) closeAction closeAction;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation XMCustomAlertViewCustomCloseBtn

+ (instancetype)initCustomCloseBtnWithClickAction:(closeAction)closeAction
{
    return [[self alloc] initCustomCloseBtnWithClickAction:closeAction];
}

- (instancetype)initCustomCloseBtnWithClickAction:(closeAction)closeAction
{
    if (self = [super init]) {
        self.closeAction = closeAction;
        //初始化按钮
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 26.f, 26.f)];
        [_closeBtn setImage:[UIImage xm_imageWithName:@"xm_loginClose"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clickAction
{
    if (self.closeAction) {
        self.closeAction(self);
    }
    else {
        [XMCustomAlertView destroyShowingAlertViewWithAnimated:YES];
    }
}

- (instancetype)init
{
    return [self initCustomCloseBtnWithClickAction:nil];
}

- (UIView *)customView
{
    return self.closeBtn;
}

- (BOOL)changeCustomViewWithModifyHandler:(AlertCustomViewModifyHandler)modifyHandler
{
    if (modifyHandler) {
        modifyHandler(self.closeBtn);
        return YES;
    }
    return NO;
}

@end

@interface XMCustomAlertViewCustomTitle()

@property (nonatomic, strong) XMAlertViewTitleBuilder *titleBuilder;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *modifyHandlerList;
@property (nonatomic, strong) CustomBackgroundView *backgroundView;

@end

@implementation XMCustomAlertViewCustomTitle

+ (instancetype)customTitleWithConfigurationHandler:(void (^ __nullable)(XMAlertViewTitleBuilder * _Nonnull))configurationHandler
{
    return [[self alloc] initCustomTitleWithConfigurationHandler:configurationHandler];
}

- (instancetype)initCustomTitleWithConfigurationHandler:(void (^ __nullable)(XMAlertViewTitleBuilder * _Nonnull))configurationHandler
{
    if (self = [super init]) {
        XMAlertViewTitleBuilder *titleBuiler = [[XMAlertViewTitleBuilder alloc] init];
        ///获取初始化配置
        if (configurationHandler) {
            configurationHandler(titleBuiler);
        }
        self.titleBuilder = titleBuiler;
        self.modifyHandlerList = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init
{
    return [self initCustomTitleWithConfigurationHandler:nil];
}

- (BOOL)changeCustomViewWithModifyHandler:(void (^)(__kindof UIView * _Nonnull))modifyHandler
{
    if (modifyHandler && self.modifyHandlerList) {
        [self.modifyHandlerList addObject:[modifyHandler copy]];
        return YES;
    }
    return NO;
}

- (UIView *)customView
{
    [self setupCustomTitle];
    for (AlertCustomViewModifyHandler modifyHandler in self.modifyHandlerList) {
        modifyHandler(self.titleLabel);
        [self fixTitleLabelHeight];
    }
    
    _backgroundView = [[CustomBackgroundView alloc] initWithFrame:self.titleLabel.frame];
    CGRect frame = self.titleLabel.frame;
    frame.size.height = self.titleLabel.frame.size.height + self.titleBuilder.bottomEdgeInset;
    _backgroundView.frame = frame;
    _backgroundView.userInteractionEnabled = NO;
    [self.backgroundView addSubview:self.titleLabel];
    return self.backgroundView;
}

- (void)fixTitleLabelHeight
{
    CGFloat labelWidth = [XMCustomAlertViewTool contentViewWidth];
    CGSize sizeThatFits = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
    self.titleLabel.frame = CGRectMake(0.f, 0.f, labelWidth, sizeThatFits.height);
}

- (void)setupCustomTitle
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.titleLabel.attributedText = [self customAlertViewAttributedTitle:self.titleBuilder];
    [self fixTitleLabelHeight];
}

- (NSAttributedString *)customAlertViewAttributedTitle:(XMAlertViewTitleBuilder *)titleBuilder
{
    if (titleBuilder.attributeTitle.string) {
        return titleBuilder.attributeTitle;
    }
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:KCustomViewTextFontSize18];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, nil];
    [attributes setObject:titleBuilder.titleColor forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:titleBuilder.title attributes:attributes];;
}

#pragma mark - private Method
- (XMAlertViewTitleBuilder *)configurationContext
{
    return self.titleBuilder;
}

@end
///================================================  类分割线  ========================================///


@interface XMCustomAlertViewCustomMessage ()

@property (nonatomic, strong) XMAlertViewMessageBuilder *messageBuilder;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSMutableArray *modifyHandlerList;
@property (nonatomic, strong) CustomBackgroundView *backgroundView;

@end

@implementation XMCustomAlertViewCustomMessage

+ (instancetype)customMessageWithConfigurationHandler:(void (^ __nullable)(XMAlertViewMessageBuilder * _Nonnull))configurationHandler
{
    return [[self alloc] initCustomMessageWithConfigurationHandler:configurationHandler];
}

- (instancetype)initCustomMessageWithConfigurationHandler:(void (^ __nullable)(XMAlertViewMessageBuilder * _Nonnull))configurationHandler
{
    if (self = [super init]) {
        XMAlertViewMessageBuilder *messageBuilder = [[XMAlertViewMessageBuilder alloc] init];
        ///获取初始化配置
        if (configurationHandler) {
            configurationHandler(messageBuilder);
        }
        self.messageBuilder = messageBuilder;
        self.modifyHandlerList = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init
{
    return [self initCustomMessageWithConfigurationHandler:nil];
}

- (BOOL)changeCustomViewWithModifyHandler:(void (^)(__kindof UIView * _Nonnull))modifyHandler
{
    if (modifyHandler && self.modifyHandlerList) {
        [self.modifyHandlerList addObject:[modifyHandler copy]];
        return YES;
    }
    return NO;
}

- (UIView *)customView
{
    [self setupMessageLabel];
    for (AlertCustomViewModifyHandler modifyHandler in self.modifyHandlerList) {
        modifyHandler(self.messageLabel);
        [self fixMessageLabelHeight];
    }
    
    _backgroundView = [[CustomBackgroundView alloc] initWithFrame:self.messageLabel.frame];
    CGRect frame = self.messageLabel.frame;
    frame.size.height = self.messageLabel.frame.size.height + self.messageBuilder.bottomEdgeInset;
    _backgroundView.frame = frame;
    [self.backgroundView addSubview:self.messageLabel];
    return self.backgroundView;
}

- (void)fixMessageLabelHeight
{
    CGFloat labelWidth = [XMCustomAlertViewTool contentViewWidth];
    CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
    self.messageLabel.frame = CGRectMake(0.f, 0.f, labelWidth, messageLabelSize.height);
}

- (void)setupMessageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.messageLabel.attributedText = [self customAlertViewAttributedMessage:self.messageBuilder];
    
    [self fixMessageLabelHeight];
    
    if (self.messageBuilder.messageAlignment != NSTextAlignmentLeft) {
        self.messageLabel.textAlignment = self.messageBuilder.messageAlignment;
    }
    else {
        if (self.messageLabel.frame.size.height <= self.oneRowHeihtOfMessageLabel) { //不超过一行居中显示
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
            CGRect frame = self.messageLabel.frame;
            frame.size.height = self.oneRowHeihtOfMessageLabel - 8.f;
            self.messageLabel.frame = frame;
        }
        else {
            self.messageLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (NSAttributedString *)customAlertViewAttributedMessage:(XMAlertViewMessageBuilder *)messageBuilder
{

    if (messageBuilder.attributeMessage.string) {
        return messageBuilder.attributeMessage;
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:KCustomViewTextFontSize15];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:KLineSpacing];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, messageBuilder.messageColor, NSForegroundColorAttributeName, nil];
    
    if (messageBuilder.boldMessage) {
        [attributes setObject:[UIFont boldSystemFontOfSize:KCustomViewTextFontSize15] forKey:NSFontAttributeName];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:messageBuilder.message attributes:attributes];
    
    return attributedString;
}

- (CGFloat)oneRowHeihtOfMessageLabel
{
    CGSize sizeToFit = CGSizeZero;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:KLineSpacing];
    NSDictionary *dic = @{NSFontAttributeName : self.messageLabel.font,
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    sizeToFit = [@"一行高度" boundingRectWithSize:CGSizeMake([XMCustomAlertViewTool contentViewWidth], MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return ceil(sizeToFit.height);
}

#pragma mark - private Method
- (XMAlertViewMessageBuilder *)configurationContext
{
    return self.messageBuilder;
}

@end
///================================================  类分割线  ========================================///


@interface XMCustomAlertViewAction ()

@property (nonatomic, strong) XMAlertViewButtonBuilderExtension *buttonBuilder;

@end

@implementation XMCustomAlertViewAction

+ (instancetype)actionWithConfigurationHandler:(void (^)(XMAlertViewButtonBuilder * _Nonnull))configurationHandler clickHander:(void (^)(XMCustomAlertViewAction * _Nonnull))clickHandler
{
    return [[self alloc] initActionWithConfigurationHandler:configurationHandler clickHander:clickHandler];
}

- (instancetype)initActionWithConfigurationHandler:(void (^)(XMAlertViewButtonBuilder * _Nonnull))configurationHandler clickHander:(clickAction)clickHandler
{
    if (self = [super init]) {
        XMAlertViewButtonBuilderExtension *buttonBuilder = [[XMAlertViewButtonBuilderExtension alloc] init];
        ///获取初始化配置
        if (configurationHandler) {
            configurationHandler(buttonBuilder);
        }
        buttonBuilder.clickActionBlock = clickHandler;
        self.buttonBuilder = buttonBuilder;
    }
    return self;

}

- (instancetype)init
{
    return [self initActionWithConfigurationHandler:nil clickHander:nil];
}

- (BOOL)changeActionWithChangeHandler:(void (^)(XMAlertViewButtonBuilder * _Nonnull))changeHandler
{
    ///还没有初始化
    if (!self.buttonBuilder) {
        return NO;
    }
    
    ///获取改变后的配置
    changeHandler(self.buttonBuilder);
    return YES;
}

///特殊类型，不需要返回具体的customView,AlertView内部会使用tableView实现按钮
- (UIView *)customView
{
    return nil;
}

#pragma mark - getter Method
- (NSString *)title
{
    return self.buttonBuilder.buttonTitle;
}

- (NSAttributedString *)attributeTitle
{
    return self.buttonBuilder.attributeTitle;
}

- (BOOL)isBold
{
    return self.buttonBuilder.boldButton;
}

#pragma mark - private Method
- (XMAlertViewButtonBuilderExtension *)configurationContext
{
    return self.buttonBuilder;
}

@end
///================================================  类分割线  ========================================///


@interface XMCustomAlertViewCustomContract () <TTTAttributedLabelDelegate>
//配置
@property (nonatomic, strong) XMAlertViewContractBuilder *contractBuilder;
@property (nonatomic, copy) checkboxAction checkboxAction;

//内部控件
@property (nonatomic, strong) TTTAttributedLabel *contractLabel;
@property (nonatomic, strong) UIImageView *identifyImageView;
@property (nonatomic, strong) UIButton *identifyButton;
@property (nonatomic, strong) CustomBackgroundView *backgroundView;

@property (nonatomic, strong) NSMutableArray *modifyHandlerList;

@end

@implementation XMCustomAlertViewCustomContract

- (instancetype)init
{
    return [self initContractWithConfigurationHandler:nil checkboxAction:nil];
}

+ (instancetype)contractWithConfigurationHandler:(void (^)(XMAlertViewContractBuilder * _Nonnull))configurationHandler checkboxAction:(checkboxAction)checkboxAction
{
    return [[self alloc] initContractWithConfigurationHandler:configurationHandler checkboxAction:checkboxAction];
}

- (instancetype)initContractWithConfigurationHandler:(void (^)(XMAlertViewContractBuilder * _Nonnull))configurationHandler checkboxAction:(checkboxAction)checkboxAction
{
    if (self = [super init]) {
        XMAlertViewContractBuilder *contractBuilder = [[XMAlertViewContractBuilder alloc] init];
        if (configurationHandler) {
            configurationHandler(contractBuilder);
        }
        self.contractBuilder = contractBuilder;
        self.checkboxAction = checkboxAction;
        _agreeContract = YES;
        self.modifyHandlerList = [NSMutableArray array];
    }
    return self;
}

- (BOOL)changeCustomViewWithModifyHandler:(AlertCustomViewModifyHandler)modifyHandler
{
    if (self.modifyHandlerList && modifyHandler) {
        [self.modifyHandlerList addObject:[modifyHandler copy]];
        return YES;
    }
    return NO;
}

- (UIView *)customView
{
    [self assembleCustomView];
    for (AlertCustomViewModifyHandler modifyHandler in self.modifyHandlerList) {
        modifyHandler(self.contractLabel);
    }
    
    _backgroundView = [[CustomBackgroundView alloc] initWithFrame:CGRectMake(0, 0, [XMCustomAlertViewTool contentViewWidth], self.contractLabel.frame.size.height + self.contractBuilder.bottomEdgeInset + 4.f)];
    [_backgroundView addSubview:self.identifyImageView];
    [_backgroundView addSubview:self.identifyButton];
    [_backgroundView addSubview:self.contractLabel];
    
    return _backgroundView;
}

- (void)assembleCustomView
{
    if (!_contractLabel) {
        _identifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        _identifyImageView.image = [UIImage xm_imageWithName:self.contractBuilder.agreeImageName];
        
        _identifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = _identifyButton.frame;
        frame.size.width = 18.f;
        frame.size.height = 18.f;
        _identifyButton.frame = frame;
        [_identifyButton addTarget:self action:@selector(checkboxAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _contractLabel = [[TTTAttributedLabel alloc] init];
        _contractLabel.numberOfLines = 0;
        _contractLabel.textAlignment = NSTextAlignmentLeft;
        _contractLabel.textColor = [UIColor colorWithRed:70.0/255.0 green:145.0/255.0 blue:238.0/255.0 alpha:1.0];
        _contractLabel.delegate = self;
    }
    
    NSString *imageName = nil;
    if (self.agreeContract) {
        imageName = self.contractBuilder.agreeImageName;
    }
    else {
        imageName = self.contractBuilder.refuseImageName;
    }
    _identifyImageView.image = [UIImage xm_imageWithName:imageName];
    
    NSString *text = [[NSString alloc] init];
    for (XMAlertViewContractModel *contractModel in self.contractBuilder.contractModelArray) {
        if (contractModel.text) {
            text = [text stringByAppendingString:contractModel.text];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [self.contractLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        UIFont *font = [UIFont systemFontOfSize:KCustomViewTextFontSize15];
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        
        if (fontRef) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, mutableAttributedString.length)];
            CFRelease(fontRef);
        }
        
        for (XMAlertViewContractModel *contractModel in weakSelf.contractBuilder.contractModelArray) {
            if (contractModel.text) {
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)contractModel.textColor.CGColor range:contractModel.range];
            }
        }
        return mutableAttributedString;
    }];
    
    self.contractLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    self.contractLabel.activeLinkAttributes = [NSDictionary dictionaryWithObject:self.contractBuilder.activeLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
    
    // 添加链接
    for (XMAlertViewContractModel *contractModel in self.contractBuilder.contractModelArray) {
        if (contractModel.text && contractModel.linkable) {
            [self.contractLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ld",contractModel.index]] withRange:contractModel.range];
        }
    }
    
    CGFloat leftMagen = self.contractBuilder.checkable ? (self.identifyImageView.frame.size.width + 6.f) : 0.f;
    CGFloat labelWidth = [XMCustomAlertViewTool contentViewWidth] - leftMagen;
    CGSize labelSize = [self.contractLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
    self.contractLabel.frame = CGRectMake(self.identifyImageView.frame.size.width + 6.f, 4.f, labelWidth, labelSize.height);
    
    if (self.contractBuilder.checkable) {
        CGPoint center = self.identifyImageView.center;
        center.y = self.contractLabel.center.y;
        self.identifyImageView.center = center;
        CGRect frame = self.identifyImageView.frame;
        frame.origin.x = 0.f;
        self.identifyImageView.frame = frame;
        
        frame = CGRectMake(0.f, 0.f, self.contractLabel.frame.origin.x, self.contractLabel.frame.size.height + 4.f);
        self.identifyButton.frame = frame;
    }
    else {
        self.identifyImageView.hidden = YES;
        self.identifyButton.hidden = YES;
        CGRect frame = self.contractLabel.frame;
        frame.origin.x = 0.f;
        self.contractLabel.frame = frame;
    }
    
}

- (void)checkboxAction:(UIButton *)btn
{
    _agreeContract = !self.agreeContract;
    btn.selected = self.agreeContract;
    
    NSString *imageName = nil;
    if (btn.selected) {
        imageName = self.contractBuilder.agreeImageName;
    }
    else {
        imageName = self.contractBuilder.refuseImageName;
    }
    _identifyImageView.image = [UIImage xm_imageWithName:imageName];
    
    if (self.checkboxAction) {
        self.checkboxAction(btn.selected);
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSUInteger index = [url.absoluteString integerValue];
    if (index < self.contractBuilder.contractModelArray.count) {
        XMAlertViewContractModel *contractModel = [self.contractBuilder.contractModelArray objectAtIndex:index];
        XMContractModelAction action = contractModel.clickAction;
        if (action) {
            action(contractModel);
        }
    }
}

@end
///================================================  类分割线  ========================================///

static CGFloat KFillSeatsWidth = 40.f;

@interface XMCustomAlertViewSlideController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *slideZoneView;
@property (nonatomic, strong) UILabel *slideZoneLabel;
@property (nonatomic, strong) UIView *verificationView;
@property (nonatomic, strong) UILabel *verificationLabel;
@property (nonatomic, strong) UIImageView *slideView;

@property (nonatomic, strong) XMAlertViewSlideBuilder *slideBuilder;
@property (nonatomic, copy) verificationSuccessfulAction successfulAction;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation XMCustomAlertViewSlideController

- (void)dealloc
{
    [self.slideView removeGestureRecognizer:self.panGestureRecognizer];
}

+ (instancetype)initSlideWithConfigurationHandler:(void (^)(XMAlertViewSlideBuilder * _Nonnull))configurationHandler verificationSuccessfulAction:(verificationSuccessfulAction)verificationSuccessfulAction
{
    return [[self alloc] initSlideWithConfigurationHandler:configurationHandler verificationSuccessfulAction:verificationSuccessfulAction];
}

- (instancetype)initSlideWithConfigurationHandler:(void (^)(XMAlertViewSlideBuilder * _Nonnull))configurationHandler verificationSuccessfulAction:(verificationSuccessfulAction)verificationSuccessfulAction
{
    if (self = [super init]) {
        XMAlertViewSlideBuilder *slideBuilder = [[XMAlertViewSlideBuilder alloc] init];
        if (configurationHandler) {
            configurationHandler(slideBuilder);
        }
        self.slideBuilder = slideBuilder;
        self.successfulAction = verificationSuccessfulAction;
    }
    return self;
}

- (instancetype)init
{
    return [self initSlideWithConfigurationHandler:nil verificationSuccessfulAction:nil];
}

- (UIView *)customView
{
    [self initSubViews];
    return self.backgroundView;
}

- (void)initSubViews
{
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [XMCustomAlertViewTool contentViewWidth], self.slideBuilder.height)];
    
    self.slideZoneView = [[UIView alloc] initWithFrame:CGRectMake(0, self.slideBuilder.edgeTop, [XMCustomAlertViewTool contentViewWidth], self.slideBuilder.slideHeight)];
    self.slideZoneView.backgroundColor = self.slideBuilder.backgroundColor;
    [self.backgroundView addSubview:self.slideZoneView];
    
    self.slideZoneLabel = [[UILabel alloc] initWithFrame:self.slideZoneView.frame];
    self.slideZoneLabel.textColor = [UIColor colorWithRed: 102.0 / 255.0 green: 102.0 /255.0 blue: 102.0 / 255.0 alpha:1.0];
    self.slideZoneLabel.font = [UIFont systemFontOfSize:KCustomViewTextFontSize15];
    self.slideZoneLabel.textAlignment = NSTextAlignmentCenter;
    self.slideZoneLabel.text = self.slideBuilder.backgroundTips;
    [self.backgroundView addSubview:self.slideZoneLabel];
    
    self.verificationView = [[UIView alloc] initWithFrame:self.slideZoneView.frame];
    CGRect frame = self.slideView.frame;
    frame.size.width = self.slideBuilder.slideHeight;
    self.verificationView.frame = frame;
    self.verificationView.backgroundColor = self.slideBuilder.verificationColor;
    [self.backgroundView addSubview:self.verificationView];
    
    self.verificationLabel = [[UILabel alloc] initWithFrame:self.slideZoneView.frame];
    self.verificationLabel.textColor = [UIColor colorWithRed:254.0 / 255.0 green:254.0 / 255.0 blue:254.0 / 255.0 alpha:1.0];
    self.verificationLabel.font = [UIFont systemFontOfSize:KCustomViewTextFontSize15];
    self.verificationLabel.textAlignment = NSTextAlignmentCenter;
    self.verificationLabel.text = self.slideBuilder.verificationSuccessTips;
    self.verificationLabel.hidden = YES;
    [self.backgroundView addSubview:self.verificationLabel];
    
    self.slideView = [[UIImageView alloc] initWithImage:[UIImage xm_imageWithName:self.slideBuilder.slideImageName]];
    self.slideView.frame = CGRectMake(0, self.slideBuilder.edgeTop, self.slideBuilder.slideHeight, self.slideBuilder.slideHeight);
    self.slideView.userInteractionEnabled = YES;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.slideView addGestureRecognizer:self.panGestureRecognizer];
    [self.backgroundView addSubview:self.slideView];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint translation = [recognizer translationInView:self.backgroundView];
            CGFloat x = recognizer.view.frame.origin.x + translation.x;
            if (x > 0.f) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.slideZoneLabel.alpha = 0.f;
                }];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:self.backgroundView];
            CGFloat x = recognizer.view.frame.origin.x + translation.x;
            CGFloat slideWidth = [XMCustomAlertViewTool contentViewWidth] - self.slideBuilder.slideHeight;
            if (recognizer.view.frame.origin.x == slideWidth || x < 0.f || x > slideWidth) {
                x = recognizer.view.frame.origin.x;
            }
            
            recognizer.view.frame = CGRectMake(x, recognizer.view.frame.origin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
            self.verificationView.frame = CGRectMake(self.verificationView.frame.origin.x, self.verificationView.frame.origin.y, CGRectGetMaxX(recognizer.view.frame), self.verificationView.frame.size.height);
            [recognizer setTranslation:CGPointZero inView:self.backgroundView];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (recognizer.view.frame.origin.x < ([XMCustomAlertViewTool contentViewWidth] - recognizer.view.frame.size.width - KFillSeatsWidth)) {
                NSTimeInterval duration = 1.f * CGRectGetMaxX(recognizer.view.frame) / [XMCustomAlertViewTool contentViewWidth];
                [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.5f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    CGRect frame = CGRectMake(0.f, recognizer.view.frame.origin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
                    recognizer.view.frame = frame;
                    CGRect verificationFrame = CGRectMake(0.f, self.verificationView.frame.origin.y, CGRectGetMaxX(frame), self.verificationView.frame.size.height);
                    self.verificationView.frame = verificationFrame;
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.2f animations:^{
                        self.slideZoneLabel.alpha = 1.f;
                    }];
                }];
            }
            else {
                [UIView animateWithDuration:0.2f delay:0 usingSpringWithDamping:1.5f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    CGRect frame = CGRectMake([XMCustomAlertViewTool contentViewWidth] - self.slideBuilder.slideHeight, recognizer.view.frame.origin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
                    recognizer.view.frame = frame;
                    frame = self.verificationView.frame;
                    frame.size.width = [XMCustomAlertViewTool contentViewWidth];
                    self.verificationView.frame = frame;
                } completion:^(BOOL finished){
                    BOOL action = self.verificationLabel.hidden;
                    self.verificationLabel.hidden = NO;
                    UIImageView *imageView = (UIImageView *)recognizer.view;
                    imageView.image = [UIImage xm_imageWithName:self.slideBuilder.verificationSuccessImageName];
                    if (action && self.successfulAction) {
                        self.successfulAction(self);
                    }
                }];
            }
        }
            break;
        default:
            break;
    }
    
}

@end


