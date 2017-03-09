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

@class M3U8SegmentListDownloader;

@protocol M3U8SegmentListDownloaderDelegate <NSObject>

- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader beginDownload:(DownloadModel *)downloadModel segment:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task;
- (void)m3u8SegmentListDownloader:(M3U8SegmentListDownloader *)segmentListDownloader updateDownload:(DownloadModel *)downloadModel progress:(CGFloat)progress;

@end

@interface M3U8SegmentListDownloader : NSObject

@property (nonatomic,strong) AFURLSessionManager *urlSession;
@property (nonatomic,weak) id<M3U8SegmentListDownloaderDelegate> delegate;

- (void)startDownload:(DownloadModel *)downloadModel andSegmentList:(M3U8SegmentList *)segmentList;
- (void)pauseDownload:(DownloadModel *)downloadModel;

@end
