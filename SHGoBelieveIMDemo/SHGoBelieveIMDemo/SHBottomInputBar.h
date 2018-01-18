//
//  SHBottomInputBar.h
//  YZLiveSDKLoading
//
//  Created by angle on 2018/1/11.
//  Copyright © 2018年 angle. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface SHBottomInputBar : UIView

@property (nonatomic, copy) void(^sendBlock)(NSString *content);

@end
