//
//  Socket_PureData.m
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "Socket_PureData.h"

@implementation Socket_PureDataReq
@synthesize ProtocolId = _ProtocolId;
-(id)init
{
    self = [super init];
    if (self) {
        _ProtocolId = PTO_PureDataReqId;
    }
    return self;
}

-(uint32_t)contentdatalength
{
    return self.m_data.length; //+ sizeof(uint32_t);
}

-(NSData *)contentData
{
    NSMutableData * data = [NSMutableData new];
    uint32_t datalength = self.m_data.length;
    writeInt32ToData(datalength, data);
    [data appendData:self.m_data];
    return data;
}
@end

@implementation Socket_ProgressNotice

+(Socket_ProgressNotice *)getRespFromData:(NSData *)data
{
    int readpointIndex = 0;
    uint32_t datalength = readNextInt32(data,&readpointIndex);
    NSLog(@"%d",datalength);
    Socket_ProgressNotice * resp = [[Socket_ProgressNotice alloc] init];
    resp.m_ProtocolId = readNextInt32(data, &readpointIndex);
    resp.m_transId = readNextInt32(data, &readpointIndex);
    resp.m_transLenInBytes = readNextInt32(data, &readpointIndex);
    resp.m_totalLenInBytes = readNextInt32(data, &readpointIndex);
    return resp;
}
@end

@implementation Socket_TransferResult

//<0000008c 00002003 00000000 0006e688 90e58a9f 00000037 00276e6f 6e61746f 2f6c5761 6f4c6138 46745479 50715154 57485647 78686935 6646755a 30454250 6700036d 70340048 68747470 3a2f2f76 6964656f 2e706d2e 70656e67 70656e67 2e636f6d 2f6e6f6e 61746f2f 6c57616f 4c613846 74547950 71515457 48564778 68693566 46755a30 45425067 2e6d7034>

//<00000026 00002003 00000001 0012e8a7 86e 9a291 e8bdace7 a081e5bc 82e5b8b8 00000000 00000000 0000>
//<00000026 00002003 00000001 0012e8a7 86e9a291 e8bdace7 a081e5bc 82e5b8b8 00000000 00000000 0000>
+(Socket_TransferResult *)getRespFromData:(NSData *)data
{
    int readpointIndex = 0;
    uint32_t datalength = readNextInt32(data,&readpointIndex);
    NSLog(@"返回的长度 %d",datalength);
    
    Socket_TransferResult * resp = [[Socket_TransferResult alloc] init];
    resp.m_ProtocolId = readNextInt32(data, &readpointIndex);//2003
    
    resp.m_retCode = readNextInt32(data, &readpointIndex);
    int stringlength = readNextInt16(data, &readpointIndex);
    resp.m_errorMsg = readNextString(data, &readpointIndex, stringlength);
    
    if (0 == resp.m_retCode) {
        resp.m_transId = readNextInt32(data, &readpointIndex);
        
        stringlength = readNextInt16(data, &readpointIndex);
        resp.m_serverFileName = readNextString(data, &readpointIndex, stringlength);
        
        stringlength = readNextInt16(data, &readpointIndex);
        resp.m_serverFileType = readNextString(data, &readpointIndex, stringlength);
        
        stringlength = readNextInt16(data, &readpointIndex);
        resp.m_accessUrl = readNextString(data, &readpointIndex, stringlength);
    }
    
    return resp;
}
@end










