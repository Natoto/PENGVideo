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
/**
 *  开始传输回复ID
 */
static int PTO_StartTransRespId     = 0x2001;
/**
 *  开始传输请求ID
 */
static int PTO_StartTransReqId      = 0x1001;
/**
 *  验证请求ID
 */
static int PTO_AuthReqId            = 0x1002;
/**
 *  验证返回ID
 */
static int PTO_AuthRespId           = 0x2002;
/**
 *  上传数据ID
 */
static int PTO_PureDataReqId        = 0x1008;
/**
 *  进度ID
 */
static int PTO_ProgressNoticeId     = 0x2005;
/**
 *  上传完成ID
 */
static int PTO_TransferResultId     = 0x2003;

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
@property(nonatomic,assign) int16_t m_retCode;
@property(nonatomic,assign) int16_t m_ProtocolId;
@property(nonatomic,strong) NSString *m_errorMsg;

+(uint32_t)pid_withsocketData:(NSData *)socketdata;
//+(Socket_PENGBaseResp *)resp_withSocketData:(NSData *)socketdata;
@end
