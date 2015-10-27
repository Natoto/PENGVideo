//
//  PENGAuth.m
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "Socket_PENGAuth.h"

@interface PENGAuthReq()
@end
@implementation PENGAuthReq
@synthesize ProtocolId = _ProtocolId;
#define  KEYPENGAUTH 0x1002

-(id)init
{
    self = [super init];
    if (self) {
        _ProtocolId = PTO_AuthReqId;//0x1002;
    }
    return self;
}

-(uint32_t)contentdatalength
{
    return self.uKey.length + self.uSecret.length;
}

+(PENGAuthReq *)reqWithKey:(NSString *)key secret:(NSString *)secret
{
    PENGAuthReq * auth = [[PENGAuthReq alloc] init];
    auth.uKey = key;
    auth.uSecret = secret;
    return auth;
}

-(NSData *)contentData
{
    NSMutableData * contentdata = [NSMutableData new];
    NSString * uKey = self.uKey;//@"nonato";
    NSString * uSecret = self.uSecret;//@"nonatopassword";
    writeStringToData(uKey, contentdata);
    writeStringToData(uSecret, contentdata);
    return contentdata;
}
 
//-(UInt32)contentdatalength
//{
//    uint32_t contentdatalength = 0xffff & (contentdata.length + 4);
//    HTONL(contentdatalength);//转换
//    return contentdatalength;
//}

-(NSMutableData *)SocketData
{
    NSMutableData * senddata = [NSMutableData new];
    NSData * contentdata = [self contentData];
    uint32_t contentdatalength = 0xffff & (contentdata.length) + 2;
    HTONL(contentdatalength);//转换
    [senddata appendBytes:&contentdatalength length:sizeof(4)];
    uint32_t ProtocolId = 0xffff & KEYPENGAUTH;// 0x1002;
    HTONL(ProtocolId);//32字节转换成网络顺序
    [senddata appendBytes:&ProtocolId length:sizeof(4)];
    [senddata appendData:contentdata];
    
    return senddata;
}
@end


@implementation PENGAuthResp
//<0000000a 00002002 00000000 0000>

+(PENGAuthResp *)getRespFromData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    int readpointIndex = 0;
    uint32_t datalength = readNextInt32(data,&readpointIndex);
    NSLog(@"%d",datalength);
    uint32_t retprotoid = readNextInt32(data,&readpointIndex);;
    uint32_t retcode = readNextInt32(data,&readpointIndex);
    uint16_t stringlength =  readNextInt16(data,&readpointIndex);
    NSString * retmsgstring;
    if (stringlength) {
        retmsgstring = readNextString(data, &readpointIndex, stringlength);
    }
    PENGAuthResp * resp = [[PENGAuthResp alloc] init];
    resp.m_retCode = retcode;
    resp.m_ProtocolId = retprotoid;
    resp.m_errorMsg = retmsgstring;
    
    return  resp;
}

@end
