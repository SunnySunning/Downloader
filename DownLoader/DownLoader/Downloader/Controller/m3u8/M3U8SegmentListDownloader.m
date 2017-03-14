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
@property (nonatomic,strong) DownloadModel *downloadingModel;
@property (nonatomic,assign) NSInteger downloadingIndex;
@property (nonatomic,strong) M3U8SegmentDownloader *segmentDownloader;
@property (nonatomic,assign) long long alreadyDownloadSize;
@property (nonatomic,assign) long long tmpSize;

@end

@implementation M3U8SegmentListDownloader

- (M3U8SegmentDownloader *)segmentDownloader
{
    if (!_segmentDownloader)
    {
        _segmentDownloader = [[M3U8SegmentDownloader alloc] init];
        _segmentDownloader.urlSession = self.urlSession;
        _segmentDownloader.delegate = self;
        _segmentDownloader.downloadCacher = self.downloadCacher;
    }
    return _segmentDownloader;
}


- (void)startDownload:(DownloadModel *)downloadModel andSegmentList:(M3U8SegmentList *)segmentList withInfo:(NSDictionary *)m3u8Info
{
    self.segmentList = segmentList;
    self.downloadingModel = downloadModel;

    self.alreadyDownloadSize = [m3u8Info[@"m3u8AlreadyDownloadSize"] integerValue];
    self.downloadingIndex = [m3u8Info[@"tsDownloadTSIndex"] integerValue];
    //NSString *resumeData = m3u8Info[@"resumeData"];
    
    if (self.downloadingIndex < [segmentList.segments count] && self.downloadingIndex > 0)
    {
        M3U8SegmentInfo *segment = [self.segmentList.segments objectAtIndex:self.downloadingIndex];
        [self _startDownload:segment withResumeData:nil];
    }
    else if (self.downloadingIndex == 0)
    {
        M3U8SegmentInfo *segment = [self.segmentList.segments firstObject];
        [self _startDownload:segment withResumeData:nil];
    }
}

- (void)pauseDownload:(DownloadModel *)downloadModel withResumeData:(NSData *)resumeData
{
    self.downloadingModel.status = DownloadPause;
    [self.segmentDownloader pauseDownloadWithResumeData:resumeData downloadIndex:self.downloadingIndex downloadSize:self.tmpSize url:self.downloadingModel.url];
}

- (void)_startDownload:(M3U8SegmentInfo *)segment withResumeData:(NSString *)resumeData
{
    [self.segmentDownloader startDownload:segment withResumeData:resumeData];
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
    self.tmpSize = self.alreadyDownloadSize + progress.completedUnitCount;
    CGFloat downloadProgress = (self.alreadyDownloadSize + progress.completedUnitCount) / (self.downloadingModel.videoSize * 1.0);
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
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:pauseDownload:resumeData:tsIndex:alreadyDownloadSize:)])
    {
        [self.delegate m3u8SegmentListDownloader:self pauseDownload:self.downloadingModel resumeData:resumeData tsIndex:self.downloadingIndex alreadyDownloadSize:self.alreadyDownloadSize];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadFailed:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:failedDownload:)])
    {
        self.downloadingModel.error = error;
        [self.delegate m3u8SegmentListDownloader:self failedDownload:self.downloadingModel];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingFinished:(M3U8SegmentInfo *)segment
{
    self.downloadingIndex++;
    if (self.downloadingIndex < [self.segmentList.segments count])
    {
        M3U8SegmentInfo *nextSegment = [self.segmentList.segments objectAtIndex:self.downloadingIndex];
        [self.segmentDownloader startDownload:nextSegment withResumeData:nil];
    }
    else//所有的ts都下载完成
    {
        [self _createM3U8File];
        if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:finishDownload:)])
        {
            [self.delegate m3u8SegmentListDownloader:self finishDownload:self.downloadingModel];
        }
    }
}

- (void)_createM3U8File
{
    NSString *savePath = [DownloadManager getM3U8LocalUrlWithVideoUrl:self.downloadingModel.url];
    savePath = [savePath stringByAppendingPathComponent:@"movie.m3u8"];
    
    //创建文件头部
    NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
    NSInteger count = [self.segmentList.segments count];
    //填充片段数据
    for(int i = 0;i<count;i++)
    {
        M3U8SegmentInfo *segInfo = [self.segmentList getSegmentByIndex:i];
        NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
        NSString *url = [NSString stringWithFormat:@"%@",segInfo.shortUrl];
        head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
    }
    //创建尾部
    NSString* end = @"#EXT-X-ENDLIST";
    head = [head stringByAppendingString:end];
    NSMutableData *writer = [[NSMutableData alloc] init];
    [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    [writer writeToFile:savePath atomically:YES];
    
}


























@end
