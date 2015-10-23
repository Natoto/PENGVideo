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
{
    int messageTag ;
    long long filesize;
    long long slicecount;
    NSString *filepath;
}
@property (weak, nonatomic) IBOutlet UITextField *txt_ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *txt_message;
@property (weak, nonatomic) IBOutlet UIButton *btn_connect;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UITextView *txt_log;

@end

@implementation UploadViewController
#define HBLOG2(STR) [self addLogText:STR];
#define MAXSLICESSIZE (1024*20)
#define DEFAULTSTARTMSGTAG 100
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"TCP SOCKET CLIENT";
    messageTag = DEFAULTSTARTMSGTAG;
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(viewTap:)];
    [self.view addGestureRecognizer:tap];
    
    [self.btn_connect setTitle:@"连接" forState:UIControlStateNormal];
    [self.btn_connect setTitle:@"断开连接" forState:UIControlStateSelected];

//传视频
//    filepath = [[NSBundle mainBundle] pathForResource:@"testvideo" ofType:@"mp4"];
//    //    NSData * data = [NSData dataWithContentsOfFile:filepath];
//    filesize = [self fileSizeAtPath:filepath];
//    slicecount =  ceilf(filesize/MAXSLICESSIZE);
//    [self sendDataWithIndex:messageTag];
//    NSLog(@"视频大小%d  一共有%d 切片 当前上传%d片",(int)filesize,(int)slicecount,messageTag);
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
    
    NSMutableData * senddata = [self DataForAuthreq];
    [asyncSocket writeData:senddata withTimeout:-1 tag:100];
    
//    NSString * msg = [NSString stringWithFormat:@"%@\r\n",self.txt_message.text];
//    NSData* xmlData = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    [asyncSocket writeData:xmlData withTimeout:-1 tag:messageTag ++];
}

//普通字符串转换为十六进制的。

- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}

//length 28 : 0000001C
//0x1002 : 00001002
//"nonato" : 00066E6F6E61746F
//"nonatopassword" : 000E6E6F6E61746F70617373776F7264

//<14000000 10020000 6e6f6e61 746f  6e6f 6e61746f 70617373 776f7264>


-(NSMutableData *)DataForAuthreq
{
    NSMutableData * senddata = [NSMutableData new];
    NSMutableData * contentdata = [NSMutableData new];
    NSString * uKey = @"nonato";
    NSString * uSecret = @"nonatopassword";
    unsigned int uklength = uKey.length; //strlen(uKey);
//    [contentdata appendBytes:&uklength  length:sizeof(uklength)];
     [contentdata appendData:[uKey dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    unsigned int uSlength = uSecret.length; //strlen(uSecret);
//    [contentdata appendBytes:&uSlength  length:sizeof(uSlength)];
//    [contentdata appendData:[NSData dataWithBytes:&uSecret length:uSlength]];
    [contentdata appendData:[uSecret dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];

    unsigned int contentdatalength = contentdata.length;
    [senddata appendBytes:&contentdatalength length:sizeof(contentdatalength)];
    unsigned int ProtocolId = 0X0210;
    [senddata appendBytes:&ProtocolId length:sizeof(ProtocolId)];
    [senddata appendData:contentdata];
    
    return senddata;
}

-(NSMutableData *)DataForAuthreq1
{
    NSMutableData * senddata = [NSMutableData new];
    NSMutableData * contentdata = [NSMutableData new];
    NSString * uKey = @"nonato";
    NSString * uSecret = @"nonatopassword";
    unsigned int uklength = uKey.length;
    
    Byte *bytes = (Byte*)[senddata bytes];
    unsigned int ip = 0;
    memcpy(&ip, bytes + 0, sizeof(unsigned int));
//    idx += sizeof(unsigned int);
    
    [contentdata appendBytes:&uklength  length:sizeof(uklength)];
    [contentdata appendData:[uKey dataUsingEncoding:NSUTF8StringEncoding]];
    unsigned int uSlength = uSecret.length;
    [contentdata appendBytes:&uSlength  length:sizeof(uSlength)];
    [contentdata appendData:[uSecret dataUsingEncoding:NSUTF8StringEncoding]];
//    [contentdata appendData:[AsyncSocket CRLFData]];
    
    unsigned int contentdatalength = contentdata.length;
    [senddata appendBytes:&contentdatalength length:sizeof(contentdatalength)];
    unsigned int ProtocolId = 0X0210;
    [senddata appendBytes:&ProtocolId length:sizeof(ProtocolId)];
//    [senddata appendData:[NSData dataWithBytes:@"\x10\x02" length:4]];
    [senddata appendData:contentdata];
    
//    <1c000000     10020000 06000000 6e6f6e61   746f0e00 00006e6f6e61746f70617373 776f7264>
//    0000001c0000  100200  066e6f6e61746f000e6e6f6e61746f70617373776f7264
   //                                   000E6E6F6E61746F70617373776F7264
    return senddata;
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

-(void)sendDataWithIndex:(long)tag
{
    NSString * msg = [NSString stringWithFormat:@"当前上传%d/%d数据块 当前进度:%.2f%%",(int)tag - DEFAULTSTARTMSGTAG,(int)slicecount,100*(tag - DEFAULTSTARTMSGTAG)/(float)slicecount];
    HBLOG2(msg)
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filepath];
    long long offset = (tag -DEFAULTSTARTMSGTAG) * MAXSLICESSIZE;
    [readHandle seekToFileOffset:offset];
    NSMutableData* sliceData  =  [NSMutableData dataWithData:[readHandle readDataOfLength:MAXSLICESSIZE]];
    [sliceData appendData:[AsyncSocket CRLFData]];
    [asyncSocket writeData:sliceData withTimeout:-1 tag:tag];
}
#pragma mark - SOCKET DELEGATE

//接收Socket数据.
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===%@",aStr);
    NSString * log = [NSString stringWithFormat:@"\n%s \n [MESSAGE]%ld: \n === %@",__func__,tag,aStr];
    HBLOG2(log)
    if (tag < slicecount) {
//        [self sendDataWithIndex:(tag + 1)];
    }
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
