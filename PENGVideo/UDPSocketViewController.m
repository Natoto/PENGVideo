//
//  UDPSocketViewController.m
//  PENGVideo
//
//  Created by zeno on 15/10/23.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "UDPSocketViewController.h"

@interface UDPSocketViewController ()<AsyncUdpSocketDelegate>
{
    int messageTag;
}
@property (weak, nonatomic) IBOutlet UITextField *txt_ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *txt_message;
@property (weak, nonatomic) IBOutlet UIButton *btn_connect;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UITextView *txt_log;
@end

@implementation UDPSocketViewController

#define HBLOG2(STR) [self addLogText:STR];

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"UDP CLIENT";
    udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(viewTap:)];
    
    [self.view addGestureRecognizer:tap];
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
    
    if(!udpSocket.isConnected || ![udpSocket connectToHost:self.txt_ip.text onPort:self.port.text.intValue error:&err])
    {
        NSLog(@"Error: %@", err);
        HBLOG2(err)
        [self.btn_connect setTitle:@"连接" forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_connect setTitle:@"断开连接" forState:UIControlStateNormal];
    }
    
}

- (IBAction)sendmessage:(id)sender {
    
    NSData* xmlData = [self.txt_message.text dataUsingEncoding:NSUTF8StringEncoding];
    //    [udpSocket writeData:xmlData withTimeout:-1 tag:messageTag ++];
    [udpSocket sendData:xmlData toHost:self.txt_ip.text port:self.port.text.intValue withTimeout:-1 tag:messageTag++];
}


-(void)addLogText:(id)log
{
    self.txt_log.text = [NSString stringWithFormat:@"%@\n%@",log,self.txt_log.text];
    //[self.txt_log.text stringByAppendingFormat:@"\n%@",log];
    //[NSString stringWithFormat:@"%@\n%@",self.txt_log.text.]
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSString * log = [NSString stringWithFormat:@"\n%s %ld",__func__,tag];
    HBLOG2(log)
    // You could add checks here
}


- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSString * log = [NSString stringWithFormat:@"\n%s %ld",__func__,tag];
    HBLOG2(log)
    // You could add checks here
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        HBLOG2(msg);//[self logMessage:FORMAT(@"RECV: %@", msg)];
    }
    else
    {
        HBLOG2(@"RECV: Unknown message from");//[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
    }
    
    [udpSocket receiveWithTimeout:-1 tag:0];
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
