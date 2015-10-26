//
//  Socket_PENG.m
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "Socket_PENG.h" 
#import "PENGAuth.h"
#import "Socket_StartTrans.h"

@implementation Socket_PENGBaseReq


-(NSData *)contentData
{
    return nil;
}

-(int32_t)contentdatalength
{
    return 0;
}

-(NSMutableData *)req_socketData:(Socket_PENGBaseReq *)basesocket
{
    NSMutableData * senddata = [NSMutableData new];
    NSData * contentdata = [basesocket contentData];
    uint32_t contentdatalength = [basesocket contentdatalength] + sizeof(uint32_t) * 2;
    //0xffff & (contentdata.length) + 8;
    HTONL(contentdatalength);//转换
    [senddata appendBytes:&contentdatalength length:sizeof(uint32_t)];
    uint32_t ProtocolId = 0xffff & basesocket.ProtocolId;// 0x1002;
    HTONL(ProtocolId);//32字节转换成网络顺序
    [senddata appendBytes:&ProtocolId length:sizeof(uint32_t)];
    [senddata appendData:contentdata];
    return senddata;
}
@end

@implementation Socket_PENGBaseResp

+(uint32_t)pid_withsocketData:(NSData *)socketdata
{
    int readpointIndex = 0;
    readNextInt32(socketdata, &readpointIndex);
    uint32_t pid = readNextInt32(socketdata, &readpointIndex);
    return pid;
}

+(Socket_PENGBaseResp *)getRespFromData:(NSData *)data
{
    return nil;
}

+(Socket_PENGBaseResp *)resp_withSocketData:(NSData *)socketdata
{
    int pid = [Socket_PENGBaseResp pid_withsocketData:socketdata];
    if (pid == PTO_AuthRespId) {
        PENGAuthResp * resp = [PENGAuthResp getRespFromData:socketdata];
        return resp;
    }
    
    return nil;
}
@end
