//
//  XMCustomAlertView.m
//  AMHexin
//
//  Created by fangxiaomin on 16/8/8.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import "XMCustomAlertView.h"
#import "XMCustomAlertViewButtonCell.h"
#import "XMEmbeddedViewController.h"
#import <CAAnimation+Blocks.h>
#import "XMAlertCutomViewClickView.h"
#import "XMCustomAlertViewTool.h"
#import "XMCustomAlertViewModelExtension.h"
#import "XMCustomAlertViewUniqueness.h"
#import "XMCustomAlertViewAnimation.h"
#import "XMCustomAlertViewConfiguration.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define WeakObj(o) __weak __typeof(o) o##Weak = o
#define StrongObj(o) __strong __typeof(o) o##Strong = o

/**
 *  该类为显示帮助类
 */
@interface XMCustomAlertViewManager : NSObject

/**
 *  获取单例
 */
+ (instancetype)shareManager;

/**
 *  将自定义alertView加入到队列中，然后逐一显示
 *
 *  @param alertView 自定义弹框
 */
- (void)showWithAlertView:(XMCustomAlertView *)alertView;

/**
 *  自定义alertView消失后调用
 */
- (void)endShowing;

/**
 *  置空正在显示的弹框
 */
- (void)cleanShowingAlertView;

/**
 *  销毁正在显示的提示框
 */
- (void)destoryFirstShowingAlertViewWithAnimated:(BOOL)animated;

/*
 *  将需要显示的消息压栈
 *
 *  @param alertView 需要压栈的提示框类
 */
- (void)pushMessage:(XMCustomAlertView *)alertView;

/**
 *  重置显示标志，然后将需要显示的消息推出
 *
 *  @param identifier 需要推出消息的标识符
 */
- (void)showMessageAfterResetFlagWithPageId:(NSString *)identifier delegate:(id)delegate;

/**
 *  销毁当前页面标识符为传入值正在显示的提示框
 *
 *  @param identifier 需要推出消息的标识符
 */
- (void)dismissShowingAlertViewWithPageIdentifier:(NSString *)identifier;

/**
 *  重置显示堆栈标志，然后将需要显示的消息推出
 */
- (void)showMessageAfterResetFlagWithStackId:(NSString *)stackIdentifier;

/**
 *  销毁当前页面堆栈标识符为传入值正在显示的提示框
 */
- (void)dismissShowingAlertViewWithStackIdentifier:(NSString *)stackIdentifier;

/**
 *  将需要提示的消息压栈并即时推出消息
 */
- (void)pushGlobalMessage:(XMCustomAlertView *)globalAlertView;

/**
 *  重置标志位
 */
- (void)resetMessageFlag;

/**
 *  清空消息栈中所有提示信息
 */
- (void)clearAllMessages;

/**
 *  是否有需要显示的信息
 *
 *  @return YES / NO
 */
- (BOOL)hasNeedShowMessage;

@end

@interface XMCustomAlertViewCustomTitle (Extension)
- (XMAlertViewTitleBuilder *)configurationContext;
@end

@interface XMCustomAlertViewCustomMessage (Extension)
- (XMAlertViewMessageBuilder *)configurationContext;
@end

typedef NS_ENUM(NSUInteger, XMCustomAlertViewType) {
    XMCustomAlertViewTypeControl,    //CustomView
    XMCustomAlertViewTypeConvenient, //便利
};

@interface XMCustomAlertViewClickState : NSObject

@property (nonatomic, assign) BOOL clickState;

@end

@implementation XMCustomAlertViewClickState

@end

static XMCustomAlertViewClickState *xmcav_getClickStateObject(NSObject *self, SEL selector) {
    
    if (!self) return nil;
    
    XMCustomAlertViewClickState *clickState = objc_getAssociatedObject(self, selector);
    if (!clickState) {
        clickState = [XMCustomAlertViewClickState new];
        clickState.clickState = NO;
        objc_setAssociatedObject(self, selector, clickState, OBJC_ASSOCIATION_RETAIN);
    }
    return clickState;
}

static void xmcav_Perform_once(NSObject *self, SEL selector, dispatch_block_t block) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);
    NSCParameterAssert(block);
    
    XMCustomAlertViewClickState *clickState = xmcav_getClickStateObject(self, selector);
    
    if (!clickState.clickState) {
        clickState.clickState = YES;
        block();
    }
}

@interface XMCustomAlertView () <UITableViewDataSource, UITableViewDelegate, XMEmbeddedViewControllerDelegate>

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIView *alertContainerView;
@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong, readonly) XMAlertCutomViewClickView *representationView;
@property (nonatomic, strong, readonly) UIView *alertBackgroundView;

@property (nonatomic, strong, readonly) UIToolbar *toolbar;
@property (nonatomic, strong, readonly) UIScrollView *scrollview;
@property (nonatomic, assign) BOOL isMoreMaxHeight;
@property (nonatomic, assign) CGSize scrollViewContentSize;

@property (nonatomic, weak) UIView *xmSuperView;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIWindow *beforeKeyWindow;
@property (nonatomic, strong) UIViewController *controller;

@property (nonatomic, assign) NSInteger visible;

@property (nonatomic, strong) XMAlertViewConfigurationContext *configurationContext;

@property (nonatomic, assign) XMCustomAlertViewType alertType;

@property (nonatomic, strong) XMCustomAlertViewCustomCloseBtn *closeBtn;
@property (nonatomic, strong) XMCustomAlertViewCustomTitle *customTitle;
@property (nonatomic, strong) XMCustomAlertViewCustomMessage *customMessage;

@property (nonatomic, strong) NSMutableArray *customViewList;

@property (nonatomic, strong) UITableView *buttonTableView; //取消Button
@property (nonatomic, strong) UITableView *otherTableView; //其他Button

@property (nonatomic, strong) XMAlertViewTitleBuilder *titleBuilder;
@property (nonatomic, strong) XMAlertViewMessageBuilder *messageBuilder;
@property (nonatomic, strong) XMCustomAlertViewAction *cancelAction;
@property (nonatomic, strong) NSMutableArray<XMCustomAlertViewAction *> *otherActionList;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign, getter=isGlobalMessage) BOOL globalMessage;

@property (nonatomic, assign) BOOL hasDelegate;

#pragma mark - MessagePush
@property (nonatomic, assign) BOOL hugEachOtherWithPage;

#pragma mark - Uniqueness
@property (nonatomic, strong) id uniqueIdentifier;
@property (nonatomic, copy) XMAlertViewComparator cmptr;

@end

@implementation XMCustomAlertView

#pragma mark - Life Cycle
- (void)dealloc
{
    //清空UITableView的Delegate（IOS8会发生崩溃）
    self.buttonTableView.delegate = nil;
    self.otherTableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithConfigurationHandler:(void (^)(XMAlertViewConfigurationContext * _Nonnull))configurationHandler
{
    if (self = [self init]) {
        if (configurationHandler) {
            configurationHandler(self.configurationContext);
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *newOtherButtonTitles = nil;
    if (otherButtonTitles) {
        va_list args;
        va_start(args, otherButtonTitles);
        newOtherButtonTitles = [[NSMutableArray alloc] initWithObjects:otherButtonTitles, nil];
        id obj;
        while ((obj = va_arg(args, id)) != nil) {
            [newOtherButtonTitles addObject:obj];
        }
        va_end(args);
    }
    
    return [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:newOtherButtonTitles clickHandler:nil];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles clickHandler:(onButtonTouchUpInside)handler
{
    if (self = [self initWithConfigurationHandler:nil]) {
        self.alertType = XMCustomAlertViewTypeConvenient;
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.clickHandler = handler;
        
        ///获取“取消按钮”配置
        XMAlertViewButtonBuilderExtension *cancelConfigurationContext = self.cancelAction.configurationContext;
        cancelConfigurationContext.buttonTitle = cancelButtonTitle;
        cancelConfigurationContext.buttonIndex = cancelButtonTitle ? 0 : -1;
        
        ///获取“其他按钮”配置
        NSInteger buttonIndex = cancelConfigurationContext.buttonIndex + 1;
        for (NSInteger i = 0; i < otherButtonTitles.count; i++) {
            NSString *otherButtonTitle = [otherButtonTitles objectAtIndex:i];
            if (otherButtonTitle != nil) {
                XMCustomAlertViewAction *otherButtonAction = [[XMCustomAlertViewAction alloc] init];
                XMAlertViewButtonBuilderExtension *otherConfigurationContext = otherButtonAction.configurationContext;
                otherConfigurationContext.fromConvenient = YES;
                otherConfigurationContext.buttonIndex = buttonIndex;
                otherConfigurationContext.buttonTitle = otherButtonTitle;
                [self.otherActionList addObject:otherButtonAction];
                buttonIndex++;
            }
        }
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        if (!other || ![other isKindOfClass:[XMCustomAlertView class]]) {
            return NO;
        }

        XMCustomAlertView *otherObject = (XMCustomAlertView *)other;

        if (self.alertType == XMCustomAlertViewTypeConvenient) {
            if (![self.titleBuilder isEqual:otherObject.titleBuilder]) {
                return NO;
            }
            if (![self.messageBuilder isEqual:otherObject.messageBuilder]) {
                return NO;
            }
            if (![self.cancelAction.configurationContext isEqual:otherObject.cancelAction.configurationContext]) {
                return NO;
            }
        }

        if (self.otherActionList.count != otherObject.otherActionList.count) {
            return NO;
        }
        for (NSInteger i = 0; i < self.otherActionList.count; i++) {
            if (![self.otherActionList[i].configurationContext isEqual:otherObject.otherActionList[i].configurationContext]) {
                return NO;
            }
        }

        ///唯一性判断Hook
        if (self.cmptr) {
           return !self.cmptr(self, otherObject);
        }
        return YES;
    }
}

- (NSUInteger)hash
{
    return [self.title integerValue] ^ [self.message integerValue] ^ [self.customViewList count] ^ [self.cancelAction.configurationContext.buttonTitle integerValue] ^ [self.otherActionList count];
}

#pragma mark - Public Methods
- (void)setTitleInfoWithBlock:(void (^)(XMAlertViewTitleBuilder *))titleInfoBlock
{
    NSParameterAssert(titleInfoBlock);
    titleInfoBlock(self.titleBuilder);
}

- (void)setMessageInfoWithBlock:(void (^)(XMAlertViewMessageBuilder *))messageInfoBlock
{
    NSParameterAssert(messageInfoBlock);
    messageInfoBlock(self.messageBuilder);
}

- (void)setButtonInfoWithIndex:(NSInteger)buttonIndex blcok:(void(^)(XMAlertViewButtonBuilder *))buttonInfoBlock
{
    NSParameterAssert(buttonInfoBlock);
    XMCustomAlertViewAction *action= [self actionWithButtonIndex:buttonIndex];
    if (action) {
        buttonInfoBlock(action.configurationContext);
    }
}

- (NSInteger)addButtonWithBlock:(void (^)(XMAlertViewButtonBuilder *))buttonInfoBlock
{
    NSParameterAssert(buttonInfoBlock);
    XMCustomAlertViewAction *action = [XMCustomAlertViewAction actionWithConfigurationHandler:nil clickHander:nil];

    buttonInfoBlock(action.configurationContext);
    
    NSInteger buttonIndex;
    if (self.otherActionList.count <= 0) {
        buttonIndex = self.cancelButtonIndex + 1;
    }
    else {
        buttonIndex = ((XMCustomAlertViewAction *)[self.otherActionList lastObject]).configurationContext.buttonIndex + 1;
    }
    
    if (action.configurationContext.buttonTitle) {
        action.configurationContext.buttonIndex = buttonIndex;
        [self.otherActionList addObject:action];
        return action.configurationContext.buttonIndex;
    }
    return -1;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    XMCustomAlertViewAction *action = [self actionWithButtonIndex:buttonIndex];
    if (action != nil) {
        return action.configurationContext.buttonTitle ?: (action.configurationContext.attributeTitle.string ?: nil);
    }
    return nil;
}

- (void)show
{
    BOOL isEmpty = !self.titleBuilder.title && !self.titleBuilder.attributeTitle.string && !self.messageBuilder.message && !self.messageBuilder.attributeMessage.string;
    
    if (self.customViewList.count <= 0) {
        if (self.alertType == XMCustomAlertViewTypeConvenient && isEmpty) {
            return;
        }
        else if (self.alertType == XMCustomAlertViewTypeControl) {
            return;
        }
    }
    
    if (!self.isVisible) {
        XMCustomAlertViewManager *manager = [XMCustomAlertViewManager shareManager];
        [manager showWithAlertView:self];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    ///清楚正在显示的弹框标志
    [[XMCustomAlertViewManager shareManager] cleanShowingAlertView];

    if (self.willDismissHandler != nil) {
        self.willDismissHandler(self, buttonIndex);
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
    }
    
    WeakObj(self);
    void (^completion)(BOOL finished) = ^(BOOL finished){
        StrongObj(selfWeak);
        // Temporary bugfix
        [selfWeakStrong removeFromSuperview];

        if (selfWeakStrong.xmSuperView) {
            [selfWeakStrong.alertContainerView removeFromSuperview];
        }
        
        // Release window from memory
        selfWeakStrong.window.hidden = YES;
        selfWeakStrong.window = nil;
        
        selfWeakStrong.visible = NO;
        
        [selfWeakStrong.buttonTableView deselectRowAtIndexPath:selfWeakStrong.buttonTableView.indexPathForSelectedRow animated:NO];
        [selfWeakStrong.otherTableView deselectRowAtIndexPath:selfWeakStrong.otherTableView.indexPathForSelectedRow animated:NO];
        
        if (selfWeakStrong.didDismissHandler != nil) {
            selfWeakStrong.didDismissHandler(selfWeakStrong, buttonIndex);
        }
        if (selfWeakStrong.delegate && [selfWeakStrong.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
            [selfWeakStrong.delegate alertView:selfWeakStrong didDismissWithButtonIndex:buttonIndex];
        }
        
        XMCustomAlertViewClickState *clickState = xmcav_getClickStateObject(selfWeakStrong, @selector(tableView:didSelectRowAtIndexPath:));
        clickState.clickState = NO;
        
        XMCustomAlertViewManager *manager = [XMCustomAlertViewManager shareManager];
        [manager endShowing];
    };
    
    if (!animated) {
        completion(YES);
    }
    else {
        [CATransaction begin]; {
            CAPropertyAnimation *dismissAnimation = self.configurationContext.dismissAnimation;
            dismissAnimation.completion = completion;
            // Zoom out the modal
            [self.representationView.layer addAnimation:dismissAnimation forKey:dismissAnimation.keyPath];
            
            CAPropertyAnimation *opacityAnimation = [[[XMAlertViewOpacityAnimationFactory alloc] init] dismissAnimation];
            [self.backgroundView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
            [self.toolbar.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
            [self.alertBackgroundView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
            [_contentView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
            [self.scrollview.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
        }
        [CATransaction commit];
    }
}

+ (void)destroyShowingAlertViewWithAnimated:(BOOL)animated
{
    [[XMCustomAlertViewManager shareManager] destoryFirstShowingAlertViewWithAnimated:animated];
}

#pragma mark - CustomView Methods
- (BOOL)modifyConfigurationContextWithHandler:(void(^)(XMAlertViewConfigurationContext *configurationContext))modifyHandler
{
    if (modifyHandler && self.configurationContext) {
        modifyHandler(self.configurationContext);
        return YES;
    }
    return NO;
}

- (BOOL)changeTitleWithModifyHandler:(void (^)(UILabel * _Nonnull))modifyHandler
{
    if (modifyHandler) {
        return [self.customTitle changeCustomViewWithModifyHandler:modifyHandler];
    }
    return NO;
}

- (BOOL)changeMessageWithModifyHandler:(void (^)(UILabel * _Nonnull))modifyHandler
{
    if (modifyHandler) {
        return [self.customMessage changeCustomViewWithModifyHandler:modifyHandler];
    }
    return NO;
}

- (BOOL)addCustomViewWithControl:(XMCustomAlertViewCustomControl *)customControl
{
    if (customControl && [customControl respondsToSelector:@selector(customView)]) {
        if ([XMCustomAlertViewTool customViewWithControl:customControl]) {
            [self.customViewList addObject:customControl];
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}

- (BOOL)addCustomViewWithView:(UIView *)customView
{
    if (customView) {
        [self.customViewList addObject:customView];
        return YES;
    }
    return NO;
}

- (BOOL)addAction:(XMCustomAlertViewAction *)action
{
    if (action.configurationContext.buttonTitle) {
        NSInteger buttonIndex;
        if (self.otherActionList.count <= 0) {
            buttonIndex = self.cancelButtonIndex + 1;
        }
        else {
            buttonIndex = ((XMCustomAlertViewAction *)[self.otherActionList lastObject]).configurationContext.buttonIndex + 1;
        }

        action.configurationContext.buttonIndex = buttonIndex;
        [self.otherActionList addObject:action];
        return YES;
    }
    return NO;
}

#pragma mark - Uniqueness Methods
- (void)uniquenessJudgeWithComparator:(XMAlertViewComparator)cmptr
{
    self.cmptr = cmptr;
}

#pragma mark - Setter And Getter
- (void)setTitle:(NSString *)title
{
    _title = title;
    if (!_titleBuilder) {
        _titleBuilder = [[XMAlertViewTitleBuilder alloc] init];
    }
    _titleBuilder.title = title;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    if (!_messageBuilder) {
        _messageBuilder = [[XMAlertViewMessageBuilder alloc] init];
    }
    _messageBuilder.message = message;
}

- (NSInteger)cancelButtonIndex
{
    return self.cancelAction.configurationContext.buttonIndex;
}

- (NSInteger)firstOtherButtonIndex
{
    return self.otherActionList.count ? (self.cancelButtonIndex + 1) : -1;
}

- (NSInteger)numberOfButtons
{
    return self.otherActionList.count + self.cancelButtonIndex + 1;
}

- (void)setDelegate:(id<XMCustomAlertViewDelegate>)delegate
{
    if (delegate != nil) {
        _hasDelegate = YES;
    }
    _delegate = delegate;
}
#pragma mark - Private Methods
- (void)assembleAlertViewWithCustomView
{
    CGFloat yOffset = self.configurationContext.contentInset.top;
    CGFloat centerX = self.configurationContext.width / 2.f;
    
    NSMutableArray<UIView *> *viewList = [NSMutableArray array];
    
    if (self.configurationContext.closeBtnSwitch) {
        WeakObj(self);
        self.closeBtn = [XMCustomAlertViewCustomCloseBtn initCustomCloseBtnWithClickAction:^(XMCustomAlertViewCustomCloseBtn * _Nonnull closeBtn) {
            if (selfWeak.configurationContext.closeBtnAction) {
                selfWeak.configurationContext.closeBtnAction();
            }
            [selfWeak dismissWithClickedButtonIndex:-1 animated:YES];
        }];
        UIView *closeBtn = [XMCustomAlertViewTool customViewWithControl:self.closeBtn];
        NSParameterAssert(closeBtn);
        CGRect frame = closeBtn.frame;
        frame.origin.x = self.configurationContext.width - 8.f - frame.size.width;
        frame.origin.y = 8.f;
        closeBtn.frame = frame;
        [viewList addObject:closeBtn];
    }
    
    if (self.alertType == XMCustomAlertViewTypeConvenient) {
        ///构建标题
        if (self.titleBuilder.title || self.titleBuilder.attributeTitle.string) {
            [self.customTitle.configurationContext copyWithOtherBuilder:self.titleBuilder];
            UIView *titleView = [XMCustomAlertViewTool customViewWithControl:_customTitle];
            NSParameterAssert(titleView);
            CGRect frame = titleView.frame;
            frame.origin.y = yOffset;
            titleView.frame = frame;
            titleView.center = CGPointMake(centerX, titleView.center.y);
            [viewList addObject:titleView];
            yOffset += titleView.frame.size.height;
        }
        
        ///构建正文
        if (self.messageBuilder.message || self.messageBuilder.attributeMessage.string) {
            [self.customMessage.configurationContext copyWithOtherBuilder:self.messageBuilder];
            UIView *messageView = [XMCustomAlertViewTool customViewWithControl:_customMessage];
            NSParameterAssert(messageView);
            CGRect frame = messageView.frame;
            frame.origin.y = yOffset;
            messageView.frame = frame;
            messageView.center = CGPointMake(centerX, messageView.center.y);
            [viewList addObject:messageView];
            yOffset += messageView.frame.size.height;
        }
    }

    ///增加自定义视图
    for (id customView in self.customViewList) {
        UIView *view = nil;
        if ([customView isKindOfClass:[XMCustomAlertViewCustomControl class]]) {
            view = [XMCustomAlertViewTool customViewWithControl:customView];
        }
        else if ([customView isKindOfClass:[UIView class]]) {
            view = customView;
        }

        NSParameterAssert(view);
        if (!view) {
            continue;
        }
        CGRect frame = view.frame;
        frame.origin.y = yOffset;
        view.frame = frame;
        view.center = CGPointMake(centerX, view.center.y);
        [viewList addObject:view];
        yOffset += view.frame.size.height;
    }
    
    ///构建Action
    yOffset += self.configurationContext.contentInset.bottom;

    ///判断是否需要滚动
    if (self.configurationContext.hasPanel &&
        self.configurationContext.scrollable &&
        ((yOffset + self.p_buttonsHeight) > [XMCustomAlertViewTool maxAlertViewHeight])) {
        self.isMoreMaxHeight = YES;
        self.scrollViewContentSize = CGSizeMake(self.configurationContext.width, yOffset);
        yOffset = [XMCustomAlertViewTool maxAlertViewHeight]  - self.p_buttonsHeight;
    }
    
    UIView *lineView;
    if (self.numberOfButtons > 0) {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, yOffset - 1.0, self.configurationContext.width, 1.0)];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        UIView *lineViewInner = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.5, self.configurationContext.width, 0.5)];
        lineViewInner.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
        lineViewInner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [lineView addSubview:lineViewInner];
    }
    
    BOOL sideBySideButtons = (self.numberOfButtons == 2);
    
    if (sideBySideButtons) {
        
        CGFloat halfWidth = (self.configurationContext.width / 2.0);
        
        UIView *lineVerticalViewInner = [[UIView alloc] initWithFrame:CGRectMake(halfWidth, 0.5,0.5, KButtonHeight + 0.5)];
        lineVerticalViewInner.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0];
        [lineView addSubview:lineVerticalViewInner];
        
        _buttonTableView = [self tableViewWithFrame:CGRectMake(0.0, yOffset, halfWidth, KButtonHeight)];
        _otherTableView  = [self tableViewWithFrame:CGRectMake(halfWidth, yOffset, halfWidth, KButtonHeight)];
        
        yOffset += KButtonHeight;
    }
    else {
        
        NSInteger numberOfOtherButtons = self.otherActionList.count;
        
        if (numberOfOtherButtons > 0) {
            CGFloat tableHeight = numberOfOtherButtons * KButtonHeight;
            
            _otherTableView = [self tableViewWithFrame:CGRectMake(0.0, yOffset, self.configurationContext.width, tableHeight)];
            
            yOffset += tableHeight;
        }
        
        if (self.cancelAction.configurationContext.buttonIndex != -1) {
            _buttonTableView  = [self tableViewWithFrame:CGRectMake(0.0, yOffset, self.configurationContext.width, KButtonHeight)];
            
            yOffset += KButtonHeight;
        }
    }
    
    _buttonTableView.tag = CANCELTABLETAG;
    _otherTableView.tag = OTHERTABLETAG;
    
    [_buttonTableView reloadData];
    [_otherTableView reloadData];
    
    CGFloat alertHeight = yOffset;
    [self p_setupWithSize:CGSizeMake(self.configurationContext.width, alertHeight)];
    
    for (UIView *customView in viewList) {
        if (self.isMoreMaxHeight) {
            [self.scrollview addSubview:customView];
        }
        else {
            [_contentView addSubview:customView];
        }
    }

    [_contentView addSubview:self.buttonTableView];
    [_contentView addSubview:self.otherTableView];
    [_contentView addSubview:lineView];
}

- (void)p_setupWithSize:(CGSize)size
{
    CGSize screenSize;
    if (self.xmSuperView) {
        screenSize = self.xmSuperView.bounds.size;
    }
    else {
        screenSize = [XMCustomAlertViewTool countScreenSize];
    }
    
    // Main container that fits the whole screen
    _alertContainerView = [[UIView alloc] initWithFrame:(CGRect){.size = screenSize}];
    _alertContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _backgroundView = [[UIView alloc] initWithFrame:_alertContainerView.frame];
    _backgroundView.backgroundColor = self.configurationContext.backgroundColor;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_alertContainerView addSubview:_backgroundView];
    
    _representationView = [[XMAlertCutomViewClickView alloc] initWithFrame:(CGRect){.size = size}];
    _representationView.center = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0);
    _representationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (self.configurationContext.hasPanel) {
        _toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){.size = self.representationView.frame.size}];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_toolbar.layer setMasksToBounds:YES];
        [_toolbar.layer setCornerRadius:self.configurationContext.panelCornerRadius];
        [self.representationView addSubview:_toolbar];

        _alertBackgroundView = [[UIView alloc] initWithFrame:(CGRect){.size = self.representationView.frame.size}];
        _alertBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _alertBackgroundView.backgroundColor = self.configurationContext.panelColor;
        [_alertBackgroundView.layer setMasksToBounds:YES];
        [_alertBackgroundView.layer setCornerRadius:self.configurationContext.panelCornerRadius];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage xm_imageWithName:@"xm_radial"]];
        imageView.frame = _toolbar.frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_alertBackgroundView addSubview:imageView];
        
        [self.representationView addSubview:_alertBackgroundView];
    }
    
    _contentView = [[UIView alloc] initWithFrame:(CGRect){.size = self.representationView.frame.size}];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentView.tag = CONTENTVIEWTAG;
    
    if (self.isMoreMaxHeight) {
        _scrollview = [[UIScrollView alloc] initWithFrame:(CGRect){.size = {self.representationView.frame.size.width, self.representationView.frame.size.height - self.p_buttonsHeight}}];
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.contentSize = self.scrollViewContentSize;
        [_contentView addSubview:_scrollview];
    }
    
    [self.representationView addSubview:_contentView];
    
    [self.representationView addSubview:self];
    
    [self.alertContainerView addSubview:self.representationView];
}

- (CGFloat)p_buttonsHeight
{
    if (self.numberOfButtons <= 0) {
        return 0.f;
    }
    else if (self.numberOfButtons <= 2) {
        return KButtonHeight;
    }
    else {
        return self.numberOfButtons * KButtonHeight;
    }
}

- (void)p_show
{
    ///组装UI控件
    [self assembleAlertViewWithCustomView];
    
    if (self.willPresentHandler != nil) {
        self.willPresentHandler(self);
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:self];
    }
    
    if (self.xmSuperView) {
        [self.xmSuperView addSubview:self.alertContainerView];
    }
    else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

        XMEmbeddedViewController *viewController = [[XMEmbeddedViewController alloc] init];
        viewController.delegate = self;
        self.window.rootViewController = viewController;
        self.window.backgroundColor = [UIColor clearColor];
        self.window.windowLevel = UIWindowLevelAlert;
        self.window.hidden = NO;

        self.beforeKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.window makeKeyAndVisible];

        if (self.controller == nil) {
            viewController.view = self.alertContainerView;
        }
        else {
            UIViewController *viewController2 = [[UIViewController alloc] init];
            viewController2.view = self.alertContainerView;
            [viewController presentViewController:viewController2 animated:NO completion:nil];
            [viewController2 addChildViewController:self.controller];
        }
    }
    
    _visible = YES;
    
    [CATransaction begin]; {
        
        CAPropertyAnimation *showAnimation = self.configurationContext.showAnimation;
        WeakObj(self);
        showAnimation.completion = ^(BOOL finished){
            if (selfWeak.didPresentHandler != nil) {
                selfWeak.didPresentHandler(selfWeak);
            }
            else if (selfWeak.delegate && [selfWeak.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
                [selfWeak.delegate didPresentAlertView:selfWeak];
            }
        };
        
        [self.representationView.layer addAnimation:showAnimation forKey:showAnimation.keyPath];
        
        CAPropertyAnimation *opacityAnimation = [[[XMAlertViewOpacityAnimationFactory alloc] init] showAnimation];
        
        [self.backgroundView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
        [self.toolbar.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
        [self.alertBackgroundView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
        [_contentView.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
        [self.scrollview.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
    }
    [CATransaction commit];
}

#pragma mark - Table DataSource & Delegate
- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMCustomAlertViewAction *action = nil;
    if (self.numberOfButtons == 1) {
        if (self.cancelButtonIndex != -1) {
            action = self.cancelAction;
        }
        else {
            action = [self otherActionWithIndexPath:indexPath.row];
        }
        action.configurationContext.isLastRow = YES;
    }
    else if (self.numberOfButtons == 2) {  //Side by Side
        if (self.cancelButtonIndex != -1) {
            if (tableView.tag == CANCELTABLETAG) {
                action = self.cancelAction;
            }
            else {
                action = [self otherActionWithIndexPath:indexPath.row];
            }
        }
        else {
            if (tableView.tag == CANCELTABLETAG) {
                action = [self otherActionWithIndexPath:0];
            }
            else {
                action = [self otherActionWithIndexPath:1];
            }
        }
        action.configurationContext.isLastRow = YES;
    }
    else {
        if (tableView.tag == CANCELTABLETAG) {
            action = self.cancelAction;
            action.configurationContext.isLastRow = YES;
        }
        else {
            action = [self otherActionWithIndexPath:indexPath.row];
            
            if (self.cancelButtonIndex == -1 && (action.configurationContext.buttonIndex == (self.otherActionList.count - 1))) {
                action.configurationContext.isLastRow = YES;
            }
        }
    }
    
    XMCustomAlertViewButtonCell *cell = [[XMCustomAlertViewButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.action = action;
    cell.isLastRow = action.configurationContext.isLastRow;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.numberOfButtons <= 2) {
        return 1;
    }
    else {
        if (tableView.tag == OTHERTABLETAG) {
            return self.otherActionList.count;
        }
        else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KButtonHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    xmcav_Perform_once(self, @selector(tableView:didSelectRowAtIndexPath:), ^{
        XMCustomAlertViewButtonCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        XMCustomAlertViewAction *action = cell.action;
        
        [self transformKeyWind];
        
        [[XMCustomAlertViewManager shareManager] cleanShowingAlertView];
        
        clickAction actionBlock = action.configurationContext.clickActionBlock;
        if (actionBlock) {
            actionBlock(action);
        }
        else if (self.clickHandler != nil) {
            self.clickHandler(self, cell.buttonIndex);
        }
        else if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
            [self.delegate alertView:self clickedButtonAtIndex:cell.buttonIndex];
        }
        
        [self dismissWithClickedButtonIndex:cell.buttonIndex animated:YES];
    });
}

#pragma mark - XMEmbeddedViewControllerDelegate
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self dismissWithClickedButtonIndex:-1 animated:YES];
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.representationView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.representationView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2.0, ([[UIScreen mainScreen] bounds].size.height - keyboardSize.height) / 2.0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.representationView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.representationView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2.0, [[UIScreen mainScreen] bounds].size.height / 2.0);
}

#pragma mark - Tools Methods
- (void)commonInit
{
    self.alertType = XMCustomAlertViewTypeControl;
    self.configurationContext = [[XMAlertViewConfigurationContext alloc] init];
    self.customTitle = [[XMCustomAlertViewCustomTitle alloc] init];
    self.customMessage = [[XMCustomAlertViewCustomMessage alloc] init];
    self.cancelAction = [[XMCustomAlertViewAction alloc] init];
    self.cancelAction.configurationContext.buttonIndex = -1;;
    self.customViewList = [NSMutableArray array];
    self.otherActionList = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UITableView *)tableViewWithFrame:(CGRect)frame
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    return tableView;
}

- (XMCustomAlertViewAction *)actionWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 0) {
        return nil;
    }
    
    if (self.cancelAction.configurationContext.buttonIndex == buttonIndex) {
        return self.cancelAction;
    }
    
    for (XMCustomAlertViewAction *otherAction in self.otherActionList) {
        if (otherAction.configurationContext.buttonIndex == buttonIndex) {
            return otherAction;
        }
    }
    
    return nil;
}

- (XMCustomAlertViewAction *)otherActionWithIndexPath:(NSInteger)row
{
    if (self.otherActionList.count <= row) {
        return nil;
    }
    else {
        return self.otherActionList[row];
    }
}

- (void)transformKeyWind
{
    //改变当前window的KeyWindow属性
    if (self.beforeKeyWindow) {
        [self.beforeKeyWindow makeKeyWindow];
    }
}

@end


#pragma mark - XMCustomAlertView (MessagePush)
@implementation XMCustomAlertView (MessagePush)

- (void)xm_pushMessageWithPageIdentifier:(NSString *)identifier
{
    self.identifier = identifier;
    [[XMCustomAlertViewManager shareManager] pushMessage:self];
}

- (void)xm_pushGlobalMessage
{
    self.globalMessage = YES;
    [[XMCustomAlertViewManager shareManager] pushGlobalMessage:self];
}

+ (void)xm_showMessageWithPageIdentifier:(NSString *)identifier delegateObject:(id)delegate;
{
    [[XMCustomAlertViewManager shareManager] showMessageAfterResetFlagWithPageId:identifier delegate:delegate];
}

+ (void)xm_dismissShowingAlertViewWithPageIdentifier:(NSString *)identifier
{
    [[XMCustomAlertViewManager shareManager] dismissShowingAlertViewWithPageIdentifier:identifier];
}

+ (void)xm_showMessageWithStackIdentifier:(NSString *)stackIdentifier
{
    [[XMCustomAlertViewManager shareManager] showMessageAfterResetFlagWithStackId:stackIdentifier];
}

+ (void)xm_dismissShowingAlertViewWithStackIdentifier:(NSString *)stackIdentifier
{
    [[XMCustomAlertViewManager shareManager] dismissShowingAlertViewWithStackIdentifier:stackIdentifier];
}

+ (void)xm_resetMessageFlag
{
    [[XMCustomAlertViewManager shareManager] resetMessageFlag];
}

+ (void)xm_clearAllMessages
{
    [[XMCustomAlertViewManager shareManager] clearAllMessages];
}

+ (BOOL)xm_hasNeedShowMessage
{
    return [[XMCustomAlertViewManager shareManager] hasNeedShowMessage];
}
@end


@interface XMCustomAlertViewManager ()

#pragma mark - ImmediatePropertys
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, weak) UIView *firstResponder; //处理键盘事件
@property (nonatomic, weak) XMCustomAlertView *showingAlertView; //目前正在显示的提示框
@property (nonatomic, assign) BOOL isShwoing; //正在显示

#pragma mark - PushAndShowPropertys
@property (nonatomic, strong) NSMutableArray *pushQueue;
@property (nonatomic, copy) NSString *identifier; //需要出栈的提示框pageIdentifier
@property (nonatomic, copy) NSString *stackIdentifier; //需要出栈的提示框stackIdentifier

@property (nonatomic, weak) id<XMCustomAlertViewDelegate> delegate; //identifier标识符页面对象

@end

@implementation XMCustomAlertViewManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    static XMCustomAlertViewManager *g_manager = nil;
    dispatch_once(&onceToken, ^{
        if (g_manager == nil) {
            g_manager = [[self alloc] init];
        }
    });
    
    return g_manager;
}

#pragma mark - ImmediateMethods
- (void)showWithAlertView:(XMCustomAlertView *)alertView
{
    if ([self isAlone:alertView]) {
        [self.queue addObject:alertView];
    }
    [self showAlertView];
}

- (void)endShowing
{
    self.isShwoing = NO;
    [self showAlertView];
}

- (void)showAlertView
{
    if (!self.isShwoing) {
        self.isShwoing = YES;
        
        XMCustomAlertView *alertView = [self needShowAlertView];
        if (alertView != nil) {
            //隐藏键盘
            UIView *firstResponder = [self appFirstResponderView];
            if (firstResponder != nil) {
                if (!self.firstResponder) {
                    self.firstResponder = firstResponder;
                    [self.firstResponder resignFirstResponder];
                }
                else {
                    if (self.firstResponder != firstResponder) {
                        self.firstResponder = firstResponder;
                        [self.firstResponder resignFirstResponder];
                    }
                }
            }
            
            [alertView p_show];
        }
        else {
            //显示键盘
            if (self.firstResponder != nil) {
                [self.firstResponder becomeFirstResponder];
                self.firstResponder = nil;
            }
            self.showingAlertView = nil;
            self.isShwoing = NO;
        }
    }
}

- (void)cleanShowingAlertView
{
    self.showingAlertView = nil;
}

- (void)removeInactivationAlertView
{
    NSMutableArray *alertArray = [NSMutableArray array];
    for (XMCustomAlertView *alertView in self.queue) {
        if (alertView.judgeEffectiveBlock != nil) {
            if (!alertView.judgeEffectiveBlock()) {
                [alertArray addObject:alertView];
            }
        }
    }
    if (alertArray.count >0) {
        [self.queue removeObjectsInArray:alertArray];
    }
    [alertArray removeAllObjects];
    
    for (XMCustomAlertView *alertView in self.pushQueue) {
        if (alertView.judgeEffectiveBlock != nil) {
            if(!alertView.judgeEffectiveBlock()) {
                [alertArray addObject:alertView];
            }
        }
    }
    if (alertArray.count > 0) {
        [self.pushQueue removeObjectsInArray:alertArray];
    }
}

- (XMCustomAlertView *)needShowAlertView
{
    [self removeInactivationAlertView];
    
    XMCustomAlertView *needShowAlertView = [self highPriorityGlobalAlertView];
    
    if (!needShowAlertView) {
        needShowAlertView = [self highPriorityPushedAlertView];
    }
    
    if (!needShowAlertView) {
        needShowAlertView = [self highPriorityImmediateAlertView];
    }
    
    return needShowAlertView;
}

- (XMCustomAlertView *)highPriorityImmediateAlertView
{
    if (self.queue.count > 0) {
        NSInteger hightIndex = 0;
        XMCustomAlertViewPriority hightPriority = ((XMCustomAlertView *)self.queue[0]).priority;
        for (NSInteger i =1; i < self.queue.count; i++) {
            XMCustomAlertView *tmp_alertView = self.queue[i];
            if (tmp_alertView.priority > hightPriority) {
                hightIndex = i;
                hightPriority = tmp_alertView.priority;
            }
        }
        XMCustomAlertView *hightPriorityAlertView = self.queue[hightIndex];
        self.showingAlertView = hightPriorityAlertView;
        [self.queue removeObjectAtIndex:hightIndex];
        return hightPriorityAlertView;
    }
    return nil;
}

- (XMCustomAlertView *)highPriorityGlobalAlertView
{
    if (self.pushQueue.count > 0) {
        NSInteger highIndex = -1;
        XMCustomAlertViewPriority highPriority = XMCustomAlertViewPriority_Low;
        for (NSUInteger i = 0; i < self.pushQueue.count; i++) {
            XMCustomAlertView *tmp_alertView = self.pushQueue[i];
            if (tmp_alertView.isGlobalMessage && tmp_alertView.priority > highPriority) {
                highIndex = i;
                highPriority = tmp_alertView.priority;
            }
        }
        if (highIndex > -1) {
            XMCustomAlertView *globalAlertView = self.pushQueue[highIndex];
            self.showingAlertView = globalAlertView;
            [self.pushQueue removeObjectAtIndex:highIndex];
            return globalAlertView;
        }
    }
    return nil;
}

- (XMCustomAlertView *)highPriorityPushedAlertView
{
    if (self.pushQueue.count >0) {
        NSInteger highIndex = -1;
        XMCustomAlertViewPriority highPriority = XMCustomAlertViewPriority_Low;
        for (NSUInteger i = 0; i < self.pushQueue.count; i++) {
            XMCustomAlertView *tmp_alertView = self.pushQueue[i];
            if (!tmp_alertView.isGlobalMessage && tmp_alertView.priority > highPriority && ([tmp_alertView.identifier isEqualToString:self.identifier] || [tmp_alertView.identifier isEqualToString:self.stackIdentifier])) {
                highIndex = i;
                highPriority = tmp_alertView.priority;
            }
        }
        if (highIndex > -1) {
            XMCustomAlertView *pushAlertView = self.pushQueue[highIndex];
            if (pushAlertView.hasDelegate && !pushAlertView.delegate && self.delegate != nil) {
                pushAlertView.delegate = self.delegate;
            }
            self.showingAlertView = pushAlertView;
            [self.pushQueue removeObjectAtIndex:highIndex];
            return pushAlertView;
        }
    }
    return nil;
}

- (BOOL)isAlone:(XMCustomAlertView *)alertView
{
    if (!alertView) {
        return NO;
    }
    
    ///唯一性判断核心代码
    for (XMCustomAlertView *temp_alertView in self.queue) {
        if (temp_alertView == alertView) {
            return NO;
        }
    }
    if(alertView.alertType != XMCustomAlertViewTypeConvenient && !alertView.cmptr) {
        return YES;
    }
    else {
        if ([alertView isEqual:self.showingAlertView]) {
            return NO;
        }
        
        for (XMCustomAlertView *tmp_alertView in self.queue) {
            if ([alertView isEqual:tmp_alertView]) {
                return NO;
            }
        }
        
        return YES;
    }
}

- (BOOL)isAloneInPushQueue:(XMCustomAlertView *)alertView
{
    if (!alertView) {
        return NO;
    }
    
    for (XMCustomAlertView *temp_alertView in self.pushQueue) {
        if (temp_alertView == alertView) {
            return NO;
        }
    }
    if(alertView.alertType != XMCustomAlertViewTypeConvenient && !alertView.cmptr) {
        return YES;
    }
    else {
        if ([alertView isEqual:self.showingAlertView]) {
            return NO;
        }
        
        for (XMCustomAlertView *tmp_alertView in self.pushQueue) {
            if ([alertView isEqual:tmp_alertView]) {
                return NO;
            }
        }
        
        return YES;
    }
}

- (void)destoryFirstShowingAlertViewWithAnimated:(BOOL)animated
{
    if (self.showingAlertView != nil) {
        [self.showingAlertView transformKeyWind];
        [self.showingAlertView dismissWithClickedButtonIndex:-1 animated:animated];
    }
}

- (NSMutableArray *)queue
{
    if (_queue == nil) {
        _queue = [[NSMutableArray alloc] init];
    }
    return _queue;
}

#pragma mark - PushAndShowMethods
- (NSMutableArray *)pushQueue
{
    if (_pushQueue == nil) {
        _pushQueue = [[NSMutableArray alloc] init];
    }
    return _pushQueue;
}

- (void)pushMessage:(XMCustomAlertView *)alertView
{
    if (alertView.identifier != nil) {
        if (![self isAloneInPushQueue:alertView]) {
            return;
        }
        [self.pushQueue addObject:alertView];
        
        if ([alertView.identifier isEqualToString:self.identifier] || [alertView.identifier isEqualToString:self.stackIdentifier]) {
            [self showAlertView];
        }
    }
}

- (void)showMessageAfterResetFlagWithPageId:(NSString *)identifier delegate:(id)delegate
{
    self.identifier = identifier;
    self.delegate = delegate;
    [self showAlertView];
}

- (void)dismissShowingAlertViewWithPageIdentifier:(NSString *)identifier
{
    if (!identifier) {
        return;
    }
    
    if ([identifier isEqualToString:self.identifier]) {
        [self resetMessageFlag];
    }
    
    if (self.showingAlertView && [identifier isEqualToString:self.showingAlertView.identifier]) {
        [self.showingAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void)showMessageAfterResetFlagWithStackId:(NSString *)stackIdentifier
{
    self.stackIdentifier = stackIdentifier;
    [self showAlertView];
}

- (void)dismissShowingAlertViewWithStackIdentifier:(NSString *)stackIdentifier
{
    if (!stackIdentifier) {
        return;
    }
    
    if ([stackIdentifier isEqualToString:self.stackIdentifier]) {
        self.stackIdentifier = nil;
    }
    
    if (self.showingAlertView && [stackIdentifier isEqualToString:self.showingAlertView.identifier]) {
        [self.showingAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void)pushGlobalMessage:(XMCustomAlertView *)globalAlertView
{
    for (XMCustomAlertView *temp_alertView in self.pushQueue) {
        if (temp_alertView == globalAlertView) {
            return;
        }
    }

    [self.pushQueue addObject:globalAlertView];
    [self showAlertView];
}

- (void)resetMessageFlag
{
    self.identifier = nil;
    self.delegate = nil;
    if (self.showingAlertView || self.showingAlertView.hugEachOtherWithPage) {
        [self destoryFirstShowingAlertViewWithAnimated:NO];
    }
}

- (void)clearAllMessages
{
    if (self.pushQueue.count > 0) {
        [self.pushQueue removeAllObjects];
    }
}

- (BOOL)hasNeedShowMessage
{
    [self removeInactivationAlertView];
    
    if (self.pushQueue.count > 0 || self.queue.count > 0) {
        return YES;
    }
    return NO;
}
#pragma mark - ToolsMethods
- (UIView *)appFirstResponderView
{
    UIView *firstResponder = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            firstResponder = [self firstResponderView:view];
            if (firstResponder) {
                return firstResponder;
            }
        }
    }
    return firstResponder;
}

- (UIView *)firstResponderView:(UIView *)view
{
    UIView *firstResponder = nil;
    
    if ([view isFirstResponder]) {
        return view;
    }
    
    for (UIView *subView in view.subviews) {
        firstResponder = [self firstResponderView:subView];
        if (firstResponder) {
            return firstResponder;
        };
    }
    return firstResponder;
}

@end

