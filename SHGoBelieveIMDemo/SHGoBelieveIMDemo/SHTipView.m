//
//  SHTipView.m
//
//  Created by angle on 2018/1/11.
//  Copyright © 2018年 angle. All rights reserved.
//

#import "SHTipView.h"

#define BeginAlertY 64
#define EndAlertY 100
#define ALERTHEIGHT 50
#define TitleFont [UIFont systemFontOfSize:13]
#define KEYWINDOW [UIApplication sharedApplication].keyWindow

@interface SHTipView ()

@property (nonatomic,strong)UIImageView *imgV;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UIView *backGroundView;

@end

@implementation SHTipView


-(UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.layer.cornerRadius = 5;
    }
    return _backGroundView;
}
-(UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
    }
    return _imgV;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = TitleFont;
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.backGroundView];
        
        [self.backGroundView addSubview:self.imgV];
        
        [self.backGroundView addSubview:self.titleLabel];
        
    }
    return self;
}

+ (void)showError:(NSString *)title style:(SHProgressTipStyle)style{
    
    SHTipView *alertV = [[SHTipView alloc] initWithFrame:KEYWINDOW.bounds];
    
    [alertV showImage:[UIImage imageNamed:@"toast_wrong"] status:title];
    
    [alertV setAlertFrame];
    
    [KEYWINDOW addSubview:alertV];
    
    [alertV showAnmView];
    
}

+ (void)showSuccess:(NSString *)title style:(SHProgressTipStyle)style{
    
    SHTipView *alertV = [[SHTipView alloc] initWithFrame:KEYWINDOW.bounds];
    
    [alertV showImage:[UIImage imageNamed:@"toast_right"] status:title];
    
    [alertV setAlertFrame];
    
    [KEYWINDOW addSubview:alertV];
    
    [alertV showAnmView];
    
}
+ (void)showTitle:(NSString *)title style:(SHProgressTipStyle)style{
    
    SHTipView *alertV = [[SHTipView alloc] initWithFrame:KEYWINDOW.bounds];
    
    [alertV showImage:nil status:title];
    
    [alertV setAlertFrame];
    
    [KEYWINDOW addSubview:alertV];
    
    [alertV showAnmView];
    
}
+ (void)showTitle:(NSString *)title withSuperView:(UIView *)superView frame:(CGRect)frame {
    SHTipView *alertV = [[SHTipView alloc] initWithFrame:frame];
    [alertV showImage:nil status:title];
    [alertV setAlertFrame];
    [superView addSubview:alertV];
    [alertV showAnmView];
}

+ (void)showTitle:(NSString *)title withSuperView:(UIView *)superView {
    SHTipView *alertV = [[SHTipView alloc] initWithFrame:superView.bounds];
    [alertV showImage:nil status:title];
    [alertV setAlertFrame];
    [superView addSubview:alertV];
    [alertV showAnmView];
}
- (void)showImage:(UIImage *)img status:(NSString *)status{
    
    self.imgV.image = img;
    NSString *titleStr = status;
    CGFloat lineS = 0;
    if (titleStr.length > 11) {
        titleStr = [titleStr substringToIndex:11];
        lineS = 5;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:status];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (img) {
        paragraphStyle.alignment = NSTextAlignmentLeft;
    }else{
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }
    [paragraphStyle setLineSpacing:lineS];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [status length])];
    self.titleLabel.attributedText = attributedString;
    
}

- (void)setAlertFrame{
    
    self.backGroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    CGSize imgSize;
    imgSize.width  = self.imgV.image.size.width > 0 ? self.imgV.image.size.width : -3 ;
    imgSize.height = self.imgV.image.size.height;
    NSString *titleStr = self.titleLabel.attributedText.string;
    if (titleStr.length > 11) {
        titleStr = [titleStr substringToIndex:11];
    }
    CGRect sizea = [titleStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TitleFont} context:nil];
    CGFloat width = sizea.size.width;
    CGFloat bgWith = width + imgSize.width + 19;
    self.backGroundView.frame = CGRectMake(0, BeginAlertY, bgWith, ALERTHEIGHT);
    self.backGroundView.alpha = 0;
    CGPoint center = self.backGroundView.center;
    center.x = self.center.x;
    self.backGroundView.center = center;
    if (imgSize.width > 0) {
        self.imgV.frame = CGRectMake(8, ALERTHEIGHT/2 - imgSize.height/2, imgSize.width, imgSize.height);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.imgV.frame) + 3, 0 , width, ALERTHEIGHT);
    }else{
        self.imgV.frame = CGRectZero;
        self.imgV.alpha = 0;
        self.titleLabel.frame = CGRectMake(0, 0 , bgWith, ALERTHEIGHT);
    }
    
}

- (void) showAnmView{
    
    CGRect frame = self.backGroundView.frame;
    CGRect frame1 = self.backGroundView.frame;

    frame.origin.y = EndAlertY;
    frame1.origin.y = BeginAlertY;
    [UIView animateWithDuration:0.3 animations:^{
        self.backGroundView.frame = frame;
        self.backGroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:2 options:1 animations:^{
            self.backGroundView.frame = frame1;
            self.backGroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
