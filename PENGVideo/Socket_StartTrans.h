//
//  Socket_StartTrans.h
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket_PENG.h"
@interface Socket_StartTransReq : Socket_PENGBaseReq
/**
 *  // 附加信息，用于扩展
 */
@property(nonatomic,assign) UInt32 m_meta;
/**
 *  文件原始的名字，不带后缀
 */
@property(nonatomic,strong) NSString * m_ofrFileName;
/**
 *  // 文件原始的名称后缀，不带点号
 */
@property(nonatomic,strong) NSString * m_oriFileType;
/**
 *  // 待传输文件的总大小，以字节为单位
 */
@property(nonatomic,assign) UInt32 m_dataLenInBytes;
@end


//<00000014 00002001 00000000 0006e688 90e58a9f 0000000a>
@interface Socket_StartTransResp : Socket_PENGBaseResp<SocketRespProtocol>
@property(nonatomic,assign) uint32_t m_ProtocolId;// = 0x2001
@property(nonatomic,assign) uint32_t m_retCode;
@property(nonatomic,strong) NSString * m_errorMsg;
@property(nonatomic,assign) uint32_t m_transId;

+(Socket_StartTransResp *)getRespFromData:(NSData *)data;
@end

