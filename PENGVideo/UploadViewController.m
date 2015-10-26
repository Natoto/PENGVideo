//
//  ViewController.m
//  TestSocket
//
//  Created by zeno on 15/10/16.
//  Copyright © 2015年 nonato. All rights reserved.
//

#import "UploadViewController.h"
#import "AsyncSocket.h"
#import "PENGAuth.h"
#import "Socket_PENG.h" 
#import "Socket_StartTrans.h"
#import "Socket_PureData.h"

typedef enum : NSUInteger {
    SOCKET_CONNECT,
    SOCKET_AUTH,
    SOCKET_STARTTRANS,
    SOCKET_TRANSPORTING,
    SOCKET_FINSH,
    SOCKET_UNCONNECT,
} SOCKETUPLOADSTATE;
@interface UploadViewController ()<AsyncSocketDelegate>
{
    int messageTag ;
    long long filesize;
    long long slicecount;
    NSString *filepath;
}
@property (assign, nonatomic) SOCKETUPLOADSTATE uploadstate;
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
    filepath = [[NSBundle mainBundle] pathForResource:@"testvideo" ofType:@"mp4"];
    //    NSData * data = [NSData dataWithContentsOfFile:filepath];
    filesize = [self fileSizeAtPath:filepath];
    slicecount =  ceilf(filesize/MAXSLICESSIZE);
    NSLog(@"视频大小%d  一共有%d 切片 当前上传%d片",(int)filesize,(int)slicecount,messageTag);
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
//TODO:STEP 1
- (IBAction)sendmessage:(id)sender {
    
    PENGAuthReq * req = [PENGAuthReq reqWithKey:@"nonato" secret:@"nonatopassword"]; // [self DataForAuthreq];
    NSMutableData * senddata = [req req_socketData:req];
    [asyncSocket writeData:senddata withTimeout:-1 tag:messageTag ++];
    HBLOG2(senddata);
    
//    NSString * msg = [NSString stringWithFormat:@"%@\r\n",self.txt_message.text];
//    NSData* xmlData = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    [asyncSocket writeData:xmlData withTimeout:-1 tag:messageTag ++];
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

//TODO:step:2
//<00000013 00001001 00000000 0004676f 6f640003 6d703400 0016d8>
-(void)startTrans
{
    filepath = [[NSBundle mainBundle] pathForResource:@"testvideo" ofType:@"mp4"];
    filesize = [self fileSizeAtPath:filepath];
    self.uploadstate = SOCKET_STARTTRANS;
    Socket_StartTransReq * req = [[Socket_StartTransReq alloc] init];
    req.m_meta = 0;
    req.m_ofrFileName = @"good";
    req.m_oriFileType = @"mp4";
    req.m_dataLenInBytes = MAXSLICESSIZE; //(uint32_t)filesize;
    NSData * reqdata = [req req_socketData:req];
    [asyncSocket writeData:reqdata withTimeout:-1 tag:messageTag ++];
    HBLOG2(reqdata);
}
//TODO:step:3
-(void)pureData
{
//    [self sendDataWithIndex:messageTag++];
    int tag = messageTag ++;
    NSString * msg = [NSString stringWithFormat:@"当前上传%d/%d数据块 当前进度:%.2f%%",(int)tag - DEFAULTSTARTMSGTAG,(int)slicecount,100*(tag - DEFAULTSTARTMSGTAG)/(float)slicecount];
    HBLOG2(msg)
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filepath];
    long long offset = (tag -DEFAULTSTARTMSGTAG) * MAXSLICESSIZE;
    [readHandle seekToFileOffset:offset];
    NSMutableData* sliceData  =  [NSMutableData dataWithData:[readHandle readDataOfLength:MAXSLICESSIZE]];
    Socket_PureDataReq * req = [[Socket_PureDataReq alloc] init];
    req.m_data = sliceData;
    NSData * reqdata = [req req_socketData:req];
    [asyncSocket writeData:reqdata withTimeout:-1 tag:messageTag ++];
    
//    HBLOG2(reqdata);
}
#pragma mark - SOCKET DELEGATE

//接收Socket数据.
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
   int pid = [Socket_PENGBaseResp pid_withsocketData:data];
    if (pid == PTO_AuthRespId) {
        PENGAuthResp * resp = [PENGAuthResp getRespFromData:data];
        if (resp.retCode == 0) {
            HBLOG2(@"开始传输...");
            sleep(5);
            [self startTrans];
        }
        else
        {
            HBLOG2(resp.errorMsg);
        }
    }
    else if(pid == PTO_StartTransRespId)
    {
        Socket_StartTransResp * resp = [Socket_StartTransResp getRespFromData:data];
        if (resp.m_retCode == 0) {
            HBLOG2(@"传输校验成功，开始上传视频...");
            sleep(5);
            [self pureData];
        }
        else
        {
            HBLOG2(resp.m_errorMsg);
        }
        
    }
    
    NSString * log = [NSString stringWithFormat:@"\n收到: %s \n [MESSAGE]%ld: \n protocal ID= %d",__func__,tag,pid];
    NSLog(@"%@",log);
    HBLOG2(log)
    if (tag < slicecount) {
//        [self sendDataWithIndex:(tag + 1)];
    }
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



//length 28 : 0000001C
//0x1002 : 00001002
//"nonato" : 00066E6F6E61746F
//"nonatopassword" : 000E6E6F6E61746F70617373776F7264

//<14000000 10020000 6e6f6e61 746f  6e6f 6e61746f 70617373 776f7264>
//      1c000000 10020000 06000000 6e6f6e61 746f0e00 000     06e6f6e61746f70617373776f7264
//<14000000      10020000 6e6f6e61746f                        6e6f6e61746f70617373776f7264>

//<18000000 10020000 06006e6f 6e61746f                    0e006e6f6e61746f70617373776f7264>
//<  00180000 1002000000066e6f6e61746f000e6e6f6e61746f70617373776f7264>
//<0018000e10020018     00066e6f6e61746f000e6e6f6e61746f70617373776f7264>
//<001c000e 0002001c    00066e6f 6e61746f 000e6e6f 6e61746f 70617373 776f7264>
//<0000001c00001002     00066e6f6e61746f000e6e6f6e61746f70617373776f7264>
//<0000001c 00001002 00066e6f 6e61746f 000e6e6f 6e61746f 70617373 776f7264>
// 0000001c00001002     00066e6f6e61746f000e6e6f6e61746f70617373776f7264
//
//-(NSMutableData *)DataForAuthreq
//{
//    NSMutableData * senddata = [NSMutableData new];
//    NSMutableData * contentdata = [NSMutableData new];
//    NSString * uKey = @"nonato";
//    NSString * uSecret = @"nonatopassword";
//    uint16_t  uklength = 0xff & uKey.length; //strlen(uKey);
//    HTONS(uklength);//转换
//    [contentdata appendBytes:&uklength  length:sizeof(uklength)];
//    [contentdata appendData:[uKey dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
//    uint16_t  uSlength = 0xff &  uSecret.length; //strlen(uSecret);
//    HTONS(uSlength);//转换
//    [contentdata appendBytes:&uSlength  length:sizeof(uSlength)];
//    [contentdata appendData:[uSecret dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
//    
//    uint32_t contentdatalength = 0xffff & (contentdata.length + 4);
//    HTONL(contentdatalength);//转换
//    [senddata appendBytes:&contentdatalength length:sizeof(4)];
//    uint32_t ProtocolId = 0xffff & 0x1002;
//    HTONL(ProtocolId);//32字节转换成网络顺序
//    [senddata appendBytes:&ProtocolId length:sizeof(4)];
//    [senddata appendData:contentdata];
//    
//    return senddata;
//}


//普通字符串转换为十六进制的。
//
//- (NSString *)hexStringFromString:(NSString *)string{
//    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
//    Byte *bytes = (Byte *)[myD bytes];
//    //下面是Byte 转换为16进制。
//    NSString *hexStr=@"";
//    for(int i=0;i<[myD length];i++)
//    {
//        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
//        
//        if([newHexStr length]==1)
//            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
//        else
//            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
//    }
//    return hexStr;
//}

