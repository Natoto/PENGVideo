//
//  Socket_PENGFunc.h
//  PENGVideo
//
//  Created by zeno on 15/10/26.
//  Copyright © 2015年 peng. All rights reserved.
//

#ifndef Socket_PENGFunc_h
#define Socket_PENGFunc_h

#include <stdio.h>
#import<UIKit/UIKit.h>

/**
 *  将一个字符串写入指定的data
 *
 *  @param string      字符串
 *  @param contentdata 对应的data
 */
static void writeStringToData(NSString * string,NSMutableData * contentdata)
{
    NSString * uKey = string;
    uint16_t  uklength = 0xff & string.length; //strlen(uKey);字符串长度
    HTONS(uklength);//转换
    [contentdata appendBytes:&uklength  length:sizeof(uklength)];
    [contentdata appendData:[uKey dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
}
/**
 *  将Int32写入data
 *
 *  @param number int32整形
 *  @param data   data
 */
static void writeInt32ToData(uint32_t number ,NSMutableData * data)
{
    uint32_t contentdatalength = number;
    HTONL(contentdatalength);//转换
    [data appendBytes:&contentdatalength length:sizeof(uint32_t)];
}

/**
 *  将Int16写入data
 *
 *  @param number int16整形
 *  @param data   data
 */
static void writeInt16ToData(uint16_t number ,NSMutableData * data)
{
    uint16_t contentdatalength = number;
    HTONS(contentdatalength);//转换
    [data appendBytes:&contentdatalength length:sizeof(uint16_t)];
}

/**
 *  读取二进制data里面的一个Int32数字
 *
 *  @param number32       Int32数值存放
 *  @param data           data
 *  @param readpointIndex 指针索引
 */
//<0000000a 00002002 00000000 0000>
static uint32_t readNextInt32(NSData * data,int *readpointIndex)
{
    uint32_t number = 0;
    [data getBytes:&number range:NSMakeRange(*readpointIndex, sizeof(uint32_t))];
    *readpointIndex +=sizeof(uint32_t);
    NTOHL(number);
    return number;
}

/**
 *  读取二进制data里面的一个Int16数字
 *
 *  @param number16       Int16数值存放
 *  @param data           data
 *  @param readpointIndex 指针索引
 */
static uint16_t readNextInt16(NSData * data,int *readpointIndex)
{
    uint16_t number;
    [data getBytes:&number range:NSMakeRange(*readpointIndex, sizeof(uint16_t))];
    *readpointIndex +=sizeof(uint16_t);
    NTOHS(number);
    return number;
}

/**
 *  读取二进制流里面的字符串
 *
 *  @param data           data
 *  @param readpointIndex 指针
 *  @param stringlength   字符串长度
 *
 *  @return 该字符串
 */
static NSString * readNextString(NSData * data,int *readpointIndex,int stringlength)
{
    NSString * retmsgstring;
    if (stringlength) {
        Byte  stringbytes[stringlength];
        [data getBytes:&stringbytes range:NSMakeRange(*readpointIndex, stringlength)];
        NSData *stringdata = [[NSData alloc] initWithBytes:stringbytes length:stringlength];
        retmsgstring = [[NSString alloc] initWithData:stringdata encoding:NSUTF8StringEncoding];
    }
    return retmsgstring;
}


#endif /* Socket_PENGFunc_h */
