//
//  ViewController.m
//  PENGVideo
//
//  Created by zeno on 15/10/20.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "RootViewController.h"
#import "UploadViewController.h"
#import "PlayViewController.h"
#import "SystemCaptureVideoViewController.h"
#import "CaptureViewController.h"
@interface RootViewController ()
AS_CELL_STRUCT_COMMON(play)
AS_CELL_STRUCT_COMMON(record)
AS_CELL_STRUCT_COMMON(download)
AS_CELL_STRUCT_COMMON(upload)
@end

@implementation RootViewController

GET_CELL_STRUCT_WITH(play, 播放)
GET_CELL_STRUCT_WITH(record, 录制)
GET_CELL_STRUCT_WITH(download, 下载)
GET_CELL_STRUCT_WITH(upload, 上传)

GET_CELL_SELECT_ACTION(cellstruct)
{
    if(cellstruct == self.cell_struct_play)
    {
        PlayViewController *ctr = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
        [self.navigationController pushViewController:ctr animated:YES];
    }
    else if(cellstruct == self.cell_struct_upload)
    {
        UploadViewController * ctr = [[UploadViewController alloc] init];
        [self.navigationController pushViewController:ctr animated:YES];
    }
    else if(cellstruct == self.cell_struct_record)
    {
        
        CaptureViewController *captureViewCon = [[CaptureViewController alloc] init];
//        [navCon pushViewController:captureViewCon animated:NO];
        
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:captureViewCon];
        navCon.navigationBarHidden = YES;
        [self presentViewController:navCon animated:YES completion:nil];
        
//        CaptureViewController * ctr = [[CaptureViewController alloc] init];
//        [self.navigationController pushViewController:ctr animated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    int rowindex = 0;
    [self.dataDictionary setObject:self.cell_struct_play forKey:KEY_INDEXPATH(0, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_record forKey:KEY_INDEXPATH(0, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_upload forKey:KEY_INDEXPATH(0, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_download forKey:KEY_INDEXPATH(0, rowindex++)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
