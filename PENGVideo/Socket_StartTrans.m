//
//  Socket_StartTrans.m
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "Socket_StartTrans.h"
@implementation Socket_StartTransReq
@synthesize ProtocolId = _ProtocolId;

-(id)init
{
    self = [super init];
    if (self) {
        _ProtocolId = 0x1001;
    }
    return self;
} 

-(uint32_t)contentdatalength
{
    return sizeof(int32_t) *2  + self.m_ofrFileName.length + self.m_oriFileType.length;
}

-(NSData *)contentData
{
    NSMutableData * data = [NSMutableData new];
    writeInt32ToData(self.m_meta, data);
    writeStringToData(self.m_ofrFileName, data);
    writeStringToData(self.m_oriFileType, data);
    writeInt32ToData(self.m_dataLenInBytes, data);
    return data;
} 
@end


@implementation Socket_StartTransResp

+(Socket_StartTransResp *)getRespFromData:(NSData *)data
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
    uint32_t transId = readNextInt32(data,&readpointIndex);
    
    Socket_StartTransResp * resp = [[Socket_StartTransResp alloc] init];
    resp.m_retCode = retcode;
    resp.m_errorMsg = retmsgstring;
    resp.m_ProtocolId = retprotoid;
    resp.m_transId = transId;
    return resp;
}
@end