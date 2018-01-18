//
//  SHBottomInputBar.m
//  YZLiveSDKLoading
//
//  Created by angle on 2018/1/11.
//  Copyright © 2018年 angle. All rights reserved.
//

#import "SHBottomInputBar.h"


@interface SHBottomInputBar ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textF;
@property (nonatomic, strong) UIButton *sendB;
@property (nonatomic, strong) UIImageView *lineV;

@end

@implementation SHBottomInputBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = frame.size.width;
        CGFloat heigh = frame.size.height;

        self.sendB.frame = CGRectMake(width - 68, 8, 60, heigh - 16);
        self.textF.frame = CGRectMake(8, 8, CGRectGetMinX(self.sendB.frame) - 18, heigh - 16);
        self.lineV.frame = CGRectMake(0, 0, width, 0.5);
        [self addSubview:self.textF];
        [self addSubview:self.sendB];
        [self addSubview:self.lineV];
    }
    return self;
}
#pragma mark -
#pragma mark   ==============sendClick==============
- (void)sendClick:(UIButton *)btn {
    [self endEditing:YES];
    if (self.sendBlock) {
        self.sendBlock(self.textF.text);
        self.textF.text = @"";
    }
}
#pragma mark -
#pragma mark   ==============UITextFieldDelegate==============
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.sendB.userInteractionEnabled = textField.text.length > 0;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.sendB.userInteractionEnabled = NO;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.sendB.userInteractionEnabled = textField.text.length > 0;
    return YES;
}
- (void)textChangeValue:(UITextField *)textField {
    self.sendB.userInteractionEnabled = textField.text.length > 0;
}
#pragma mark -
#pragma mark   ==============lazy==============
- (UITextField *)textF {
    if (!_textF) {
        _textF = [[UITextField alloc] init];
        _textF.delegate = self;
        _textF.borderStyle = UITextBorderStyleRoundedRect;
        [_textF addTarget:self action:@selector(textChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _textF;
}
- (UIButton *)sendB {
    if (!_sendB) {
        _sendB = [[UIButton alloc] init];
        _sendB.backgroundColor = [UIColor cyanColor];
        [_sendB setTitle:@"发送" forState:UIControlStateNormal];
        [_sendB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendB addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendB;
}
- (UIImageView *)lineV {
    if (!_lineV) {
        _lineV = [[UIImageView alloc] init];
        _lineV.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineV;
}
@end
