//
//  SHIMManger.h
//  SHGoBelieveIM
//
//  Created by angle on 2018/1/17.
//  Copyright © 2018年 angle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHIMManger;

@protocol SHIMMangerDelegate <NSObject>

/**
 消息发送成功与否

 @param im SHIMManger
 @param msg 消息体
 @param success yes 服务器接收成功， no 服务器接收失败
 */
-(void)sendMessage:(SHIMManger *)im didMessage:(NSString *)msg withState:(BOOL)success;

/**
 接收消息

 @param im SHIMManger
 @param msg 消息体
 */
-(void)receviceMessage:(SHIMManger *)im didReceiveMessage:(NSString *)msg;

/**
 接收系统消息
 
 @param im SHIMManger
 @param msg 消息体
 */
-(void)receviceSystemMessage:(SHIMManger *)im didReceiveMessage:(NSString *)msg;

/**
 连接成功

 @param im SHIMManger
 */
-(void)connectSuccessIM:(SHIMManger *)im;

/**
 断开连接
 */
-(void)closeConnectIM;

@end

@interface SHIMManger : NSObject

/**
 日志打印信息 默认yes  打印
 */
@property (nonatomic, assign) bool IMlogEnble;

/** 设备id */
@property(nonatomic, copy) NSString *deviceID;

/** host地址 */
@property(nonatomic, copy) NSString *host;

/** 发送者id */
@property (nonatomic) int64_t uid;

/** 聊天室id */
@property (nonatomic) int64_t roomID;

+ (SHIMManger *)sharedInstance;

 /** 最大重连次数，默认5次 */
@property (nonatomic, assign) int maxReconnectionCount;

@property (nonatomic,weak) id<SHIMMangerDelegate> delegate;

/** 监听网络状态变化 */
- (void)startRechabilityNotifier;

/** 进入前台 */
- (void)enterForeground;

/** 进入后台 */
- (void)enterBackground;

/** 建立连接 (token 不能为空)*/
- (void)connectToServerWithSendToken:(NSString *)token;

/** 断开连接 */
- (void)disConnect;

/** 发消息 (富文本消息可用json转string，接收是一样) */
- (void)sendString:(NSString *)msg;

@end
