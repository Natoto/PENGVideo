//
//  ViewController.m
//  TestSocket
//
//  Created by zeno on 15/10/16.
//  Copyright © 2015年 nonato. All rights reserved.
//

#import "UploadViewController.h"
#import "AsyncSocket.h"
@interface UploadViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txt_ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *txt_message;
@property (weak, nonatomic) IBOutlet UIButton *btn_connect;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UITextView *txt_log;

@end

@implementation UploadViewController
#define HBLOG(STR) [self addLogText:STR];

- (void)viewDidLoad {
    [super viewDidLoad];    
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(viewTap:)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)viewTap:(id)sender
{
    [self.txt_ip resignFirstResponder];
    [self.txt_message resignFirstResponder];
    [self.port resignFirstResponder];
}

- (IBAction)connect:(id)sender {
    
    NSError *err = nil;
    
    if(!asyncSocket.isConnected && ![asyncSocket connectToHost:self.txt_ip.text onPort:self.port.text.intValue error:&err])
    {
        NSLog(@"Error: %@", err);
        HBLOG(err)
        [self.btn_connect setTitle:@"连接" forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_connect setTitle:@"断开连接" forState:UIControlStateNormal];
    }
    
}

- (IBAction)sendmessage:(id)sender {
  
    NSData* xmlData = [self.txt_message.text dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:xmlData withTimeout:-1 tag:1];
}

- (IBAction) buttonPressed: (id)sender
{
    
}

-(void)addLogText:(id)log
{
    self.txt_log.text = [self.txt_log.text stringByAppendingFormat:@"\n%@",log];
    //[NSString stringWithFormat:@"%@\n%@",self.txt_log.text.]
}
//接收Socket数据.
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"%s %ld",__func__,tag);
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===%@",aStr);
    NSString * log = [NSString stringWithFormat:@"%s %ld",__func__,tag];
    HBLOG(log)
}


-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%s %ld",__func__,tag);
    NSString * log = [NSString stringWithFormat:@"%s %ld",__func__,tag];
    HBLOG(log)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
