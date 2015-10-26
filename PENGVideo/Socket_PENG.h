//
//  Socket_PENG.h
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "Socket_PENGFunc.h"
#import <Foundation/Foundation.h>
#import <stdio.h>

static int PTO_StartTransRespId = 0x2001;
static int PTO_StartTransReqId  = 0x1001;

static int PTO_AuthReqId        = 0x1002;
static int PTO_AuthRespId       = 0x2002;

static int PTO_PureDataReqId    = 0x1008;

@protocol SocketReqProtocol <NSObject>
@required
-(NSData *)contentData; //必须要实现的get方法
-(uint32_t)contentdatalength;
@end

@interface Socket_PENGBaseReq : NSObject<SocketReqProtocol>
@property(nonatomic,assign,readonly) uint32_t ProtocolId;
//@property(nonatomic,strong,readonly) NSData   * contentData;
-(NSMutableData *)req_socketData:(Socket_PENGBaseReq *)basesocket;
@end



@class Socket_PENGBaseResp;
@protocol SocketRespProtocol <NSObject>
@required
+(Socket_PENGBaseResp *)getRespFromData:(NSData *)data;
@end

@interface Socket_PENGBaseResp : NSObject<SocketRespProtocol>
@property(nonatomic,assign) id<SocketRespProtocol> respprotocol;
+(uint32_t)pid_withsocketData:(NSData *)socketdata;
//+(Socket_PENGBaseResp *)resp_withSocketData:(NSData *)socketdata;
@end
