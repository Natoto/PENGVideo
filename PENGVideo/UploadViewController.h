//
//  ViewController.h
//  TestSocket
//
//  Created by zeno on 15/10/16.
//  Copyright © 2015年 nonato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaAsyncSocket-umbrella.h"
#import "HBTable.h"
@interface UploadViewController : HB_BaseViewController
{ 
    AsyncSocket * asyncSocket;
}

@end

