//
//  ViewController.h
//  TestSocket
//
//  Created by zeno on 15/10/16.
//  Copyright © 2015年 nonato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaAsyncSocket-umbrella.h"

@interface UploadViewController : UIViewController
{ 
    AsyncSocket * asyncSocket;
}
@property (retain, nonatomic) IBOutlet UITextField *textField;

@end

