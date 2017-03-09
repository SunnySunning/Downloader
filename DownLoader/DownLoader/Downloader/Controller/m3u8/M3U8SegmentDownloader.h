//
//  M3U8SegmentDownloader.h
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLSessionManager.h"
#import "M3U8SegmentInfo.h"

@class M3U8SegmentDownloader;

@protocol M3U8SegmentDownloaderDelegate <NSObject>

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingBegin:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task;
- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingUpdateProgress:(NSProgress *)progress;
- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingPause:(M3U8SegmentInfo *)segment resumeData:(NSData *)resumeData;
- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadFailed:(NSError *)error;
- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingFinished:(M3U8SegmentInfo *)segment;

@end

@interface M3U8SegmentDownloader : NSObject

@property (nonatomic,strong) AFURLSessionManager *urlSession;
@property (nonatomic,weak) id<M3U8SegmentDownloaderDelegate> delegate;

- (void)startDownload:(M3U8SegmentInfo *)segment;

@end
