//
//  M3U8SegmentListDownloader.h
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentList.h"
#import "DownloadModel.h"
#import "AFURLSessionManager.h"
#import "DownloadCacher+M3U8.h"

@class M3U8SegmentListDownloader;

@protocol M3U8SegmentListDownloaderDelegate <NSObject>

- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader beginDownload:(DownloadModel *)downloadModel segment:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task;
- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader updateDownload:(DownloadModel *)downloadModel progress:(CGFloat)progress;
- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader pauseDownload:(DownloadModel *)downloadModel resumeData:(NSData *)resumeData tsIndex:(NSInteger)tsIndex alreadyDownloadSize:(long long)alreadyDownloadSize;
- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader finishDownload:(DownloadModel *)downloadModel;
- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader failedDownload:(DownloadModel *)downloadModel;

@end

@interface M3U8SegmentListDownloader : NSObject

@property (nonatomic,strong) AFURLSessionManager *urlSession;
@property (nonatomic,strong) DownloadCacher *downloadCacher;
@property (nonatomic,weak) id<M3U8SegmentListDownloaderDelegate> delegate;

+ (id)shareInstance;
- (void)startDownload:(DownloadModel *)downloadModel andSegmentList:(M3U8SegmentList *)segmentList withInfo:(NSDictionary *)m3u8Info;
- (void)pauseDownload:(DownloadModel *)downloadModel withResumeData:(NSData *)resumeData;

@end
