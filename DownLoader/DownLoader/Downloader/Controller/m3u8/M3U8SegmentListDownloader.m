//
//  M3U8SegmentListDownloader.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentListDownloader.h"
#import "M3U8SegmentDownloader.h"
#import "DownloadManager+Utils.h"

@interface M3U8SegmentListDownloader ()<M3U8SegmentDownloaderDelegate>

@property (nonatomic,strong) M3U8SegmentList *segmentList;
@property (nonatomic,strong) M3U8SegmentInfo *downloadingModel;
@property (nonatomic,assign) NSInteger downloadingIndex;
@property (nonatomic,strong) M3U8SegmentDownloader *segmentDownloader;
@property (nonatomic,assign) long long videoSize;
@property (nonatomic,assign) long long alreadyDownloadSize;

@end

@implementation M3U8SegmentListDownloader

- (M3U8SegmentDownloader *)segmentDownloader
{
    if (!_segmentDownloader)
    {
        _segmentDownloader = [[M3U8SegmentDownloader alloc] init];
        _segmentDownloader.urlSession = self.urlSession;
    }
    return _segmentDownloader;
}


- (void)startDownload:(DownloadModel *)downloadModel andSegmentList:(M3U8SegmentList *)segmentList
{
    self.segmentList = segmentList;
    self.downloadingModel = downloadModel;
    self.downloadingIndex = 0;
    M3U8SegmentInfo *segment = [self.segmentList.segments firstObject];
    [self _startDownload:segment];
}

- (void)pauseDownload:(DownloadModel *)downloadModel
{
    
}

- (void)_startDownload:(M3U8SegmentInfo *)segment
{
    [self.segmentDownloader startDownload:segment];
}



#pragma mark - SegmentDownloaderDelegate

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingBegin:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task
{
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:beginDownload:segment:task:)])
    {
        [self.delegate m3u8SegmentListDownloader:self beginDownload:nil segment:segment task:task];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingUpdateProgress:(NSProgress *)progress
{
    
    CGFloat downloadProgress = (self.alreadyDownloadSize + progress.completedUnitCount) / (self.videoSize * 1.0);
    if (progress.completedUnitCount == progress.totalUnitCount)
    {
        self.alreadyDownloadSize += progress.totalUnitCount;
    }
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:updateDownload:progress:)])
    {
        [self.delegate m3u8SegmentListDownloader:self updateDownload:nil progress:downloadProgress];
    }
    
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingPause:(M3U8SegmentInfo *)segment resumeData:(NSData *)resumeData
{
    
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingFinished:(M3U8SegmentInfo *)segment
{
    self.downloadingIndex++;
    if (self.downloadingIndex < [self.segmentList.segments count])
    {
        M3U8SegmentInfo *nextSegment = [self.segmentList.segments objectAtIndex:self.downloadingIndex];
        [self.segmentDownloader startDownload:nextSegment];
    }
    else//所有的ts都下载完成
    {
        [self _createM3U8File];
    }
}

- (void)_createM3U8File
{
    NSString *savePath = [DownloadManager getM3U8LocalUrlWithVideoUrl:self.downloadingModel.url];
    savePath = [savePath stringByAppendingString:@"movie.m3u8"];
}


























@end
