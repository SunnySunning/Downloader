//
//  DownloadManager_M3U8.h
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"
#import "AFURLSessionManager.h"
#import "DownloadCacher.h"
#import "M3U8SegmentInfo.h"

@class DownloadManager_M3U8;

@protocol DownloadManager_M3U8_Delegate <NSObject>

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader beginDownload:(DownloadModel *)downloadModel segment:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task;
- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader updateDownload:(DownloadModel *)downloadModel progress:(CGFloat)progress;
- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader pauseDownload:(DownloadModel *)downloadModel resumeData:(NSData *)resumeData tsIndex:(NSInteger)tsIndex alreadyDownloadSize:(long long)alreadyDownloadSize;
- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader failedDownload:(DownloadModel *)downloadModel;
- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader finishDownload:(DownloadModel *)downloadModel;

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader dealModelFinished:(DownloadModel *)downloadModel;
- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader analyseFailed:(DownloadModel *)downloadModel;

@end

@interface DownloadManager_M3U8 : NSObject

@property (nonatomic,strong) AFURLSessionManager *urlSession;
@property (nonatomic,strong) DownloadCacher *downloadCacher;
@property (nonatomic,weak) id<DownloadManager_M3U8_Delegate> delegate;

+ (instancetype)shareInstance;
- (void)m3u8Downloading:(DownloadModel *)downloadModel withInfo:(NSDictionary *)m3u8Info;
- (void)pauseDownloadModel:(DownloadModel *)downloadModel withResumeData:(NSData *)resumeData;

@end
