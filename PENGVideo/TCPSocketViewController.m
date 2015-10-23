//
//  TCPSocketViewController.m
//  PENGVideo
//
//  Created by zeno on 15/10/23.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "TCPSocketViewController.h"

@interface TCPSocketViewController ()
{
    int messageTag ;
}
@property (weak, nonatomic) IBOutlet UITextField *txt_ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *txt_message;
@property (weak, nonatomic) IBOutlet UIButton *btn_connect;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UITextView *txt_log;
@end

@implementation TCPSocketViewController

#define HBLOG2(STR) [self addLogText:STR];
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"TCP SOCKET CLIENT";
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(viewTap:)];
    [self.view addGestureRecognizer:tap];
    
    [self.btn_connect setTitle:@"连接" forState:UIControlStateNormal];
    [self.btn_connect setTitle:@"断开连接" forState:UIControlStateSelected];
}

-(void)viewTap:(id)sender
{
    [self.txt_ip resignFirstResponder];
    [self.txt_message resignFirstResponder];
    [self.port resignFirstResponder];
    [self.txt_log resignFirstResponder];
}

- (IBAction)connect:(id)sender {
    
    NSError *err = nil;
    if (self.btn_connect.selected) {
        self.btn_connect.selected = NO;
        [asyncSocket disconnect];
    }
    else{
        if(!asyncSocket.isConnected && ![asyncSocket connectToHost:self.txt_ip.text onPort:self.port.text.intValue error:&err]){
            NSLog(@"Error: %@", err);
            HBLOG2(err)
        }
        else{
            self.btn_connect.selected = YES;
        }
    }
}

- (IBAction)sendmessage:(id)sender {
    
        NSString * msg = [NSString stringWithFormat:@"%@\r\n",self.txt_message.text];
        NSData* xmlData = [msg dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:xmlData withTimeout:-1 tag:messageTag ++];
}

- (IBAction) buttonPressed: (id)sender
{
    
}

-(void)addLogText:(id)log
{
    self.txt_log.text = [NSString stringWithFormat:@"%@\n%@",log,self.txt_log.text];
    //[self.txt_log.text stringByAppendingFormat:@"\n%@",log];
    //[NSString stringWithFormat:@"%@\n%@",self.txt_log.text.]
}

//
//-(void)sendDataWithIndex:(long)tag
//{
//    NSString * msg = [NSString stringWithFormat:@"当前上传%d/%d数据块 当前进度:%.2f%%",(int)tag - DEFAULTSTARTMSGTAG,(int)slicecount,100*(tag - DEFAULTSTARTMSGTAG)/(float)slicecount];
//    HBLOG2(msg)
//    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filepath];
//    long long offset = (tag -DEFAULTSTARTMSGTAG) * MAXSLICESSIZE;
//    [readHandle seekToFileOffset:offset];
//    NSMutableData* sliceData  =  [NSMutableData dataWithData:[readHandle readDataOfLength:MAXSLICESSIZE]];
//    [sliceData appendData:[AsyncSocket CRLFData]];
//    [asyncSocket writeData:sliceData withTimeout:-1 tag:tag];
//}

#pragma mark - SOCKET DELEGATE

//接收Socket数据.
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===%@",aStr);
    NSString * log = [NSString stringWithFormat:@"\n%s \n [MESSAGE]%ld: \n === %@",__func__,tag,aStr];
    HBLOG2(log)
    //[sock writeData:data withTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%s %ld",__func__,tag);
    NSString * log = [NSString stringWithFormat:@"\n%s %ld",__func__,tag];
    HBLOG2(log)
    [sock readDataWithTimeout:-1 tag:tag];
}

-(void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSString * log = [NSString stringWithFormat:@"\n%s ",__func__];
    HBLOG2(log)
}
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSString * log = [NSString stringWithFormat:@"\n%s ",__func__];
    HBLOG2(log)
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSString * log = [NSString stringWithFormat:@"\n%s ",__func__];
    HBLOG2(log)
}

//断开了连接
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSString * log = [NSString stringWithFormat:@"\n%s ",__func__];
    HBLOG2(log)
    self.btn_connect.selected = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
