//
//  SHTipView.h
//
//  Created by angle on 2018/1/11.
//  Copyright © 2018年 angle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SHProgressTipStyle) {
    SHProgressTipStyleTop,
    SHProgressTipStyleCenter,
    SHProgressTipStyleBottom
};

@interface SHTipView : UIView

/**
 显示错误提示

 @param title message
 @param style 位置
 */
+ (void)showError:(NSString *)title style:(SHProgressTipStyle)style;

/**
 显示正确提示

 @param title message
 @param style 位置
 */
+ (void)showSuccess:(NSString *)title style:(SHProgressTipStyle)style;

/**
 显示提示

 @param title message
 @param style 位置
 */
+ (void)showTitle:(NSString *)title style:(SHProgressTipStyle)style;

/**
 在指定视图上显示

 @param title message
 @param superView 父视图
 @param frame 位置
 */
+ (void)showTitle:(NSString *)title withSuperView:(UIView *)superView frame:(CGRect)frame;

/**
 在指定视图上显示 默认居中

 @param title message
 @param superView 父视图
 */
+ (void)showTitle:(NSString *)title withSuperView:(UIView *)superView;

@end
