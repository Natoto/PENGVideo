//
//  ViewController.m
//  AVPlayer
//
//  Created by Kenshin Cui on 14/03/30.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
@interface PlayViewController ()
{
    BOOL _played;
    NSString *_totalTime;
    NSDateFormatter *_dateFormatter;
}
@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet PlayerView *playerView; //播放器容器
@property (weak, nonatomic) IBOutlet UIButton *stateButton; //播放/暂停按钮
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgress;//播放进度
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;
@property (nonatomic ,strong) id playbackTimeObserver;

@property (nonatomic,strong) UIButton * backButton;
@property (nonatomic,strong) UIButton * playButton;
@end

@implementation PlayViewController
#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.videoUrl) {
        NSURL *videoUrl = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
        self.videoUrl = videoUrl;
    }
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_nor.png"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"vedio_nav_btn_back_pre.png"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backtoparent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];

    
    self.playButton = [[UIButton alloc] initWithFrame:self.playerView.frame];
    [_playButton setImage:[UIImage imageNamed:@"video_icon.png"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.player = _player;
    self.stateButton.enabled = NO;
    
//    UIImage * image = [self.playerView thumbnailImageRequestWithVideoURL:videoUrl time:1];
//    self.playerView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}
#pragma mark - 播放  暂停

- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
    
    [self stateButtonTouched:nil];
}


- (IBAction)stateButtonTouched:(id)sender {
    if (!_played) {
        [self.playerView.player play];
        [self.stateButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.playerView.player pause];
        [self.stateButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    _played = !_played;
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.videoSlider setValue:0.0 animated:YES];
        [weakSelf.stateButton setTitle:@"Play" forState:UIControlStateNormal];
    }];
}

#pragma mark - 拖动 

- (IBAction)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value change:%f",slider.value);
    
    if (slider.value == 0.000000) {
        __weak typeof(self) weakSelf = self;
        [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.playerView.player play];
        }];
    }
}

- (IBAction)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
    __weak typeof(self) weakSelf = self;
    [self.playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf.playerView.player play];
        [weakSelf.stateButton setTitle:@"Stop" forState:UIControlStateNormal];
    }];
}


#pragma mark - 播放进度缓冲进度

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    
    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        [weakSelf.videoSlider setValue:currentSecond animated:YES];
        NSString *timeString = [weakSelf convertTime:currentSecond];
//        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,_totalTime];
        NSLog(@"当前播放时间:%@",timeString);
    }];
}


- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 创建移除观察监听


- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.playerView.player removeTimeObserver:self.playbackTimeObserver];
    self.playerView.player = nil;
}


- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}


- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}
@end