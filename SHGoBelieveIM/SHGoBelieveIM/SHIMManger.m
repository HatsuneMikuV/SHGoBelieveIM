//
//  SHIMManger.m
//  SHGoBelieveIM
//
//  Created by angle on 2018/1/17.
//  Copyright © 2018年 angle. All rights reserved.
//

#import "SHIMManger.h"

#import "IMService.h"


@interface SHIMManger()<RoomMessageObserver, TCPConnectionObserver>

/**
  存储重连次数
 */
@property (nonatomic, assign) int reconnectionCount;

/**
 连接认证票据
 */
@property(nonatomic, copy) NSString *token;

/**
 连接成功后，需要立即发送给服务端的数据
 */
@property (nonatomic, strong) NSMutableArray *sendMsgArr;

@end

@implementation SHIMManger

-(void)dealloc{
    if (self.IMlogEnble) NSLog(@"SHIMManger：释放了");
}

static SHIMManger *instance = nil;
static dispatch_once_t onceToken;
+ (SHIMManger *)sharedInstance{
    dispatch_once(&onceToken, ^{
        instance = [[SHIMManger alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if(self=[super init]) {
        _maxReconnectionCount = 5;
        _sendMsgArr = [NSMutableArray array];
    }
    return self;
}

#pragma makr - 建立连接
-(void)connectToServerWithSendToken:(NSString *)token{
    if (token && ![token isEqualToString:@""]) {
        _reconnectionCount = 0;
        self.token = token;
        [self connectToServer];
    }
}
- (void)connectToServer{
    [self disConnect];// 断开上次的连接
    [[IMService instance] setToken:self.token];
    [[IMService instance] start];
    [[IMService instance] enterRoom:self.roomID];//进入聊天室
    [[IMService instance] addRoomMessageObserver:self];
    [[IMService instance] addConnectionObserver:self];
}

#pragma mark - 断开连接
- (void)disConnect{
    [[IMService instance] removeRoomMessageObserver:self];
    [[IMService instance] removeConnectionObserver:self];
    [[IMService instance] leaveRoom:self.roomID];//离开聊天室
    [[IMService instance] stop];
    if (self.sendMsgArr.count) [self.sendMsgArr removeAllObjects];
}

#pragma mark - 发送数据
- (void)sendString:(NSString *)msg {
    if (msg) {
        RoomMessage *im = [[RoomMessage alloc] init];
        im.sender = self.uid;//发送者
        im.receiver = self.roomID;//发给聊天室
        im.content = msg;
        [[IMService instance] sendRoomMessage:im];
    }
}
#pragma mark - 发送失败的数据
- (void)sendOldMSGString {
    __weak __typeof(&*self)weakSelf = self;
    [self.sendMsgArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            [weakSelf sendString:obj];
        }
    }];
}
#pragma mark - 删除发送成功的数据
- (void)deleOldMSGString:(NSString *)msg {
    if (msg && [self.sendMsgArr containsObject:msg]) {
        [self.sendMsgArr removeObject:msg];
    }
}
#pragma mark - TCPConnectionObserver
//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state{
    if (state == STATE_CONNECTED) {//连接成功, 有数据则立即给服务端发数据
        _reconnectionCount = 0;
        if (self.IMlogEnble) NSLog(@"SHIMManger******连接成功");
        if ([self.delegate respondsToSelector:@selector(connectSuccessIM:)]) {
            [self.delegate connectSuccessIM:self];
        }
        if (self.sendMsgArr.count) [self sendMsgArr];
    }else if (state == STATE_CONNECTFAIL) {
        if (_reconnectionCount >= _maxReconnectionCount) {
            [self disConnect];// 关闭连接
            if (self.IMlogEnble) NSLog(@"SHIMManger******超过最大重连次数，将不再重连");
            if ([self.delegate respondsToSelector:@selector(closeConnectIM)]) {
                [self.delegate closeConnectIM];
            }
            return;// 超过最大重连次数
        }
        _reconnectionCount++;
        if (self.IMlogEnble) NSLog(@"SHIMManger******连接失败，将一秒后重连");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectToServer];
        });
    }else if (state == STATE_CONNECTING) {
        if (self.IMlogEnble) NSLog(@"SHIMManger******正在连接中...");
        if ([self.delegate respondsToSelector:@selector(closeConnectIM)]) {
            [self.delegate closeConnectIM];
        }
    }else if (state == STATE_UNCONNECTED) {
        if (self.IMlogEnble) NSLog(@"SHIMManger******连接状态未知...");
        if ([self.delegate respondsToSelector:@selector(closeConnectIM)]) {
            [self.delegate closeConnectIM];
        }
    }
}
#pragma mark - RoomMessageObserver
-(void)onRoomMessage:(RoomMessage*)rm {
    if (self.IMlogEnble) NSLog(@"SHIMManger******接收到数据，%@", rm.content);
    if ([self.delegate respondsToSelector:@selector(receviceMessage:didReceiveMessage:)]) {
        [self.delegate receviceMessage:self didReceiveMessage:rm.content];
    }
}
-(void)onRoomMessageACK:(RoomMessage*)rm {
    if (self.IMlogEnble) NSLog(@"SHIMManger******消息发送成功，%@", rm.content);
    if ([self.delegate respondsToSelector:@selector(sendMessage:didMessage:withState:)]) {
        [self.delegate sendMessage:self didMessage:rm.content withState:YES];
    }
    if (self.sendMsgArr.count) [self deleOldMSGString:rm.content];
}
-(void)onRoomMessageFailure:(RoomMessage*)rm {
    if (self.IMlogEnble) NSLog(@"SHIMManger******消息发送失败，%@", rm.content);
    if ([self.delegate respondsToSelector:@selector(sendMessage:didMessage:withState:)]) {
        [self.delegate sendMessage:self didMessage:rm.content withState:NO];
    }
    if (self.sendMsgArr) [self.sendMsgArr addObject:rm.content];
}
#pragma mark -
#pragma mark   ============================
- (void)setDeviceID:(NSString *)deviceID {
    [IMService instance].deviceID = deviceID;
}
- (void)setHost:(NSString *)host {
    [IMService instance].host = host;
}
- (void)startRechabilityNotifier {
    [[IMService instance] startRechabilityNotifier];
}
- (void)enterForeground {
    [[IMService instance] enterForeground];
}
- (void)enterBackground {
    [[IMService instance] enterBackground];
}
@end
