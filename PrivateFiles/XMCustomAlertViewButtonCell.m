//
//  XMCustomAlertViewButtonCell.m
//  AMHexin
//
//  Created by fangxiaomin on 16/8/9.
//  Copyright © 2016年 Hexin. All rights reserved.
//

#import "XMCustomAlertViewButtonCell.h"
#import "XMCustomAlertViewModelExtension.h"

@interface XMCustomAlertViewButtonCell ()

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation XMCustomAlertViewButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        NSInteger width = self.contentView.frame.size.width;
        NSInteger height = self.contentView.frame.size.height;
        self.selectedBackgroundView = [self lightBackGroundView];
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, width, height)];
        _titleLable.backgroundColor= [UIColor clearColor];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.adjustsFontSizeToFitWidth = YES;
        _titleLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_titleLable];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0.f, height - 1.f, width, 1.f)];
        _lineView.backgroundColor = [UIColor colorWithRed:221.0 / 255.0 green:221.0 / 255.0 blue:221.0 / 255.0 alpha:1.0];
        _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setAction:(XMCustomAlertViewAction *)action
{
    if (!action) {
        return;
    }
    
    _action = action;
    _buttonIndex = action.configurationContext.buttonIndex;
    self.titleLable.attributedText = [self buttonAttributeString];
}

- (void)setIsLastRow:(BOOL)isLastRow
{
    _isLastRow = isLastRow;
    self.lineView.hidden = isLastRow;
}

- (NSAttributedString *)buttonAttributeString
{
    XMAlertViewButtonBuilderExtension *buttonBuilder = self.action.configurationContext;
    
    if (buttonBuilder.attributeTitle.string) {
        return buttonBuilder.attributeTitle;
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:buttonBuilder.buttoncolor forKey:NSForegroundColorAttributeName];
   
    if (buttonBuilder.boldButton) {
        [attributes setObject:[UIFont boldSystemFontOfSize:16.f] forKey:NSFontAttributeName];
    }
    else {
        [attributes setObject:[UIFont systemFontOfSize:16.f] forKey:NSFontAttributeName];
    }
    return [[NSAttributedString alloc] initWithString:buttonBuilder.buttonTitle attributes:attributes];

}

- (UIView *)lightBackGroundView
{
    UIView *backGroundView = [[UIView alloc] initWithFrame:self.contentView.frame];
    backGroundView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.6];
    UIView *maskView = [[UIView alloc] initWithFrame:backGroundView.frame];
    maskView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.08];
    return maskView;
}

- (void)tintColorDidChange
{
    self.titleLable.textColor = self.action.configurationContext.buttoncolor ?: self.tintColor;
}

@end
