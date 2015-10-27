//
//  Socket_PureData.h
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket_PENG.h"
@interface Socket_PureDataReq : Socket_PENGBaseReq
@property(nonatomic,strong) NSData * m_data;
@end

/**
 *  上传进度
 */
@interface Socket_ProgressNotice : Socket_PENGBaseResp
@property(nonatomic,assign) uint32_t m_transId;
@property(nonatomic,assign) uint32_t m_transLenInBytes;
@property(nonatomic,assign) uint32_t m_totalLenInBytes;

+(Socket_ProgressNotice *)getRespFromData:(NSData *)data;
@end

@interface Socket_TransferResult : Socket_PENGBaseResp
@property(nonatomic,assign) uint32_t   m_transId;
@property(nonatomic,strong) NSString * m_serverFileName;
@property(nonatomic,strong) NSString * m_serverFileType;
@property(nonatomic,strong) NSString * m_accessUrl;
+(Socket_TransferResult *)getRespFromData:(NSData *)data;
@end