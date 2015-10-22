//
//  PlayerView.h
//  AVPlayerDemo
//
//  Created by CaoJie on 14-5-5.
//  Copyright (c) 2014年 yiban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView

@property (nonatomic ,strong) AVPlayer *player;

/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 *  @param url 视频的NSURL
 */
-(UIImage *)thumbnailImageRequestWithVideoURL:(NSURL *)url time:(CGFloat )timeBySecond;
@end
