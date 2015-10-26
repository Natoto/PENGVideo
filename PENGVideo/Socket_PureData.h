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
