//
//  UDPSocketViewController.h
//  PENGVideo
//
//  Created by zeno on 15/10/23.
//  Copyright © 2015年 peng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaAsyncSocket-umbrella.h"
#import "HBTable.h"

@interface UDPSocketViewController : HB_BaseViewController
{
    AsyncUdpSocket * udpSocket;
}

@end
