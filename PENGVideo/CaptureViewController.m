//
//  CaptureViewController.m
//  PENGVideo
//
//  Created by zeno on 15/10/22.
//  Copyright © 2015年 peng. All rights reserved.
//

#import "CaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SBCaptureDefine.h"
#import "SBVideoRecorder.h"
#import "SBCaptureToolKit.h"
#import "MBProgressHUD.h"
#import "ProgressBar.h"
#import "PlayViewController.h"
#import "DeleteButton.h"

@interface CaptureViewController(LAYOUT)

-(UIButton *)recordButton;
-(SBVideoRecorder *)recorder;
-(ProgressBar *)progressBar;
-(UIView *)preview;
- (UIView *)maskView;
-(DeleteButton *)deleteButton;
-(UIButton *)okButton;
- (void)initTopLayout;
@end

@interface CaptureViewController ()<SBVideoRecorderDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) MBProgressHUD * hud;
@property (strong, nonatomic) UIView    * maskView;
@property (strong, nonatomic) UIView    * preview;
@property (strong, nonatomic) UIButton  * recordButton;
@property (strong, nonatomic) UIButton  * okButton;

@property (strong, nonatomic) UIButton  * closeButton;
@property (strong, nonatomic) UIButton  * switchButton;
@property (strong, nonatomic) UIButton  * settingButton;
@property (strong, nonatomic) UIButton  * flashButton;

@property (strong, nonatomic) DeleteButton  * deleteButton;
@property (strong, nonatomic) SBVideoRecorder * recorder;
@property (strong, nonatomic) ProgressBar *progressBar;

@property (strong, nonatomic) UIImageView *focusRectView;

@property (assign, nonatomic) BOOL initalized;
@property (assign, nonatomic) BOOL isProcessingData;
@end

@implementation CaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self maskView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_initalized) {
        return;
    }
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self recordButton];
    [self preview];
    [self recorder];
    [self okButton];
    [self progressBar];
    [self deleteButton];
    [self initTopLayout];
    [self hideMaskView];
    _initalized = YES;
}

- (void)hideMaskView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.maskView.frame;
        frame.origin.y = self.maskView.frame.size.height;
        self.maskView.frame = frame;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)startRecorde:(id)sender
{
    NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
    [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
    
}

-(IBAction)stopRecord:(id)sender
{ 
    [_recorder stopCurrentVideoRecording];
}


- (void)pressDeleteButton
{
    if (_deleteButton.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
    } else if (_deleteButton.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        
        if ([_recorder getVideoCount] > 0) {
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        } else {
            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
        }
    }
}

//放弃本次视频，并且关闭页面
- (void)dropTheVideo
{
    [_recorder deleteAllVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//删除最后一段视频
- (void)deleteLastVideo
{
    if ([_recorder getVideoCount] > 0) {
        [_recorder deleteLastVideo];
    }
}

- (void)pressOKButton
{
    if (_isProcessingData) {
        return;
    }
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = @"努力处理中";
    }
    [_hud show:YES];
    [self.view addSubview:_hud];
    
    [_recorder mergeVideoFiles];
    self.isProcessingData = YES;
}


- (void)pressCloseButton
{
    if ([_recorder getVideoCount] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"放弃这个视频真的好么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        alertView.tag = 111;
        [alertView show];
    } else {
        [self dropTheVideo];
    }
}

- (void)pressSwitchButton
{
    _switchButton.selected = !_switchButton.selected;
    if (_switchButton.selected) {//换成前摄像头
        if (_flashButton.selected) {
            [_recorder openTorch:NO];
            _flashButton.selected = NO;
            _flashButton.enabled = NO;
        } else {
            _flashButton.enabled = NO;
        }
    } else {
        _flashButton.enabled = [_recorder isFrontCameraSupported];
    }
    
    [_recorder switchCamera];
}

- (void)pressFlashButton
{
    _flashButton.selected = !_flashButton.selected;
    [_recorder openTorch:_flashButton.selected];
}

#pragma mark - SBVideoRecorderDelegate
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
    
    [self.progressBar addProgressView];
    [_progressBar stopShining];
    [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"录制视频错误:%@", error);
    } else {
        NSLog(@"录制视频完成: %@", outputFileURL);
    }
    
    [_progressBar startShining];
//
    if (totalDur >= MAX_VIDEO_DUR) {
        [self pressOKButton];
    }
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    } else {
        NSLog(@"删除了视频: %@", fileURL);
        NSLog(@"现在视频长度: %f", totalDur);
    }
    if ([_recorder getVideoCount] > 0) {
        [_deleteButton setStyle:DeleteButtonStyleNormal];
    } else {
        [_deleteButton setStyle:DeleteButtonStyleDisable];
    }
    _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    NSLog(@"%s",__func__);
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];   
    _okButton.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    NSLog(@"%s",__func__);
    [_hud hide:YES];
    self.isProcessingData = NO;
    PlayViewController *playCon = [[PlayViewController alloc] init];
    playCon.videoUrl = outputFileURL;
    [self.navigationController pushViewController:playCon animated:YES];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 111:
        {
            switch (buttonIndex) {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self dropTheVideo];
                }
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}
@end

#pragma mark - getter setter

@implementation CaptureViewController(LAYOUT)

-(UIButton *)recordButton
{
    if (!_recordButton) {
        CGFloat buttonW = 80.0f;//
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_SIZE.width - buttonW) / 2.0, 400, buttonW, buttonW)];
        [_recordButton setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot.png"] forState:UIControlStateNormal];
        [_recordButton setImage:[UIImage imageNamed:@"video_longvideo_btn_pause"] forState:UIControlStateHighlighted];
        [self.view insertSubview:_recordButton belowSubview:self.maskView];
        
        [_recordButton addTarget:self action:@selector(startRecorde:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

-(SBVideoRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [[SBVideoRecorder alloc] init];
        _recorder.delegate = self;
        _recorder.preViewLayer.frame = CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.width);
        [self.preview.layer addSublayer:_recorder.preViewLayer];
    }
    return _recorder;
}

-(ProgressBar *)progressBar
{
    if (!_progressBar) {
        _progressBar = [ProgressBar getInstance];
        [SBCaptureToolKit setView:_progressBar toOriginY:DEVICE_SIZE.width];
        [self.view insertSubview:_progressBar belowSubview:_maskView];
        [_progressBar startShining];
    }
    return _progressBar;
}

-(UIView *)preview
{
    if (!_preview) {
        _preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.width)];
        _preview.clipsToBounds = YES;
        [self.view insertSubview:_preview belowSubview:self.maskView];
    }
    return _preview;
}

- (UIView *)maskView
{
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height + DELTA_Y)];
        maskView.backgroundColor = color(30, 30, 30, 1);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height)];
        label.font = [UIFont systemFontOfSize:50.0f];
        label.textColor = color(100, 100, 100, 1);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"PENG";
        label.backgroundColor = [UIColor clearColor];
        [maskView addSubview:label];
        _maskView = maskView;
        [self.view addSubview:_maskView];
    }
    return _maskView;
}

-(DeleteButton *)deleteButton
{
    if (!_deleteButton) {
        if (_isProcessingData) {
            return nil;
        }
        DeleteButton * button =  [DeleteButton getInstance];
        [button setButtonStyle:DeleteButtonStyleDisable];
        [SBCaptureToolKit setView:button toOrigin:CGPointMake(15, self.view.frame.size.height - button.frame.size.height - 10)];
        [button addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint center = button.center;
        center.y = self.recordButton.center.y;
        button.center = center;
        _deleteButton = button;
        [self.view insertSubview:_deleteButton belowSubview:_maskView];
        
    }
    return _deleteButton;
}

-(UIButton *)okButton
{
    if (!_okButton) {
        CGFloat okButtonW = 50;
        self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, okButtonW, okButtonW)];
        _okButton.enabled = NO;
        
        [_okButton setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_normal_bg.png"] forState:UIControlStateNormal];
        [_okButton setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_highlighted_bg.png"] forState:UIControlStateHighlighted];
        
        [_okButton setImage:[UIImage imageNamed:@"record_icon_hook_normal.png"] forState:UIControlStateNormal];
        
        [SBCaptureToolKit setView:_okButton toOrigin:CGPointMake(self.view.frame.size.width - okButtonW - 10, self.view.frame.size.height - okButtonW - 10)];
        
        [_okButton addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint center = _okButton.center;
        center.y = _recordButton.center.y;
        _okButton.center = center;
        
        [self.view insertSubview:_okButton belowSubview:_maskView];
    }
    return _okButton;
}


- (void)initTopLayout
{
    CGFloat buttonW = 35.0f;
    
    //关闭
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, buttonW, buttonW)];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_normal.png"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_disable.png"] forState:UIControlStateDisabled];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateSelected];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_closeButton belowSubview:_maskView];
    
    //前后摄像头转换
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10) * 2 - 10, 5, buttonW, buttonW)];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_normal.png"] forState:UIControlStateNormal];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateSelected];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateHighlighted];
    [_switchButton addTarget:self action:@selector(pressSwitchButton) forControlEvents:UIControlEventTouchUpInside];
    _switchButton.enabled = [_recorder isFrontCameraSupported];
    [self.view insertSubview:_switchButton belowSubview:_maskView];
    
    //setting
    //    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10), 5, buttonW, buttonW)];
    //    [_settingButton setImage:[UIImage imageNamed:@"record_tool_normal.png"] forState:UIControlStateNormal];
    //    [_settingButton setImage:[UIImage imageNamed:@"record_tool_disable.png"] forState:UIControlStateDisabled];
    //    [_settingButton setImage:[UIImage imageNamed:@"record_tool_highlighted.png"] forState:UIControlStateSelected];
    //    [_settingButton setImage:[UIImage imageNamed:@"record_tool_highlighted.png"] forState:UIControlStateHighlighted];
    //    [self.view insertSubview:_settingButton belowSubview:_maskView];
    
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10), 5, buttonW, buttonW)];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_normal.png"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_disable.png"] forState:UIControlStateDisabled];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateHighlighted];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateSelected];
    _flashButton.enabled = _recorder.isTorchSupported;
    [_flashButton addTarget:self action:@selector(pressFlashButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_flashButton belowSubview:_maskView];
    
    //focus rect view
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
    _focusRectView.alpha = 0;
    [self.preview addSubview:_focusRectView];
}
@end
