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
    return self.m_data.length;
}

-(NSData *)contentData
{
    return self.m_data;
}
@end
