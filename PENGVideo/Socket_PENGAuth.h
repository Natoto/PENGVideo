//
//  PENGAuth.h
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket_PENG.h"
@class Socket_PENGBaseReq;
@class Socket_PENGBaseResp;

@interface PENGAuthReq : Socket_PENGBaseReq
@property(nonatomic,strong) NSString * uKey;
@property(nonatomic,strong) NSString * uSecret;

+(PENGAuthReq *)reqWithKey:(NSString *)key secret:(NSString *)secret;
-(NSMutableData *)SocketData;
@end
 
//<00000014 00002001 00000000 0006e688 90e58a9f 0000000a>
@interface PENGAuthResp:Socket_PENGBaseResp
+(PENGAuthResp *)getRespFromData:(NSData *)data;

@end