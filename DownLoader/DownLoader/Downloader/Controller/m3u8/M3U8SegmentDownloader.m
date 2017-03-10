//
//  M3U8SegmentDownloader.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentDownloader.h"

@interface M3U8SegmentDownloader ()

@property (nonatomic,strong) M3U8SegmentInfo *segment;
@property (nonatomic,strong) NSURLSessionDownloadTask *task;

@end

@implementation M3U8SegmentDownloader

- (void)startDownload:(M3U8SegmentInfo *)segment withResumeData:(NSString *)resumeData
{
    self.segment = segment;
    __weak M3U8SegmentInfo *weakSegment = segment;

    if (resumeData)
    {
        NSData *resume = [resumeData dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDownloadTask *task = [self.urlSession
                                          downloadTaskWithResumeData:resume
                                                            progress:^(NSProgress * _Nonnull downloadProgress) {
            
                                                                    if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingUpdateProgress:)])
                                                                    {
                                                                        [self.delegate m3u8SegmentDownloader:self downloadingUpdateProgress:downloadProgress];
                                                                    }

                                                            }
                                                        destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                            return [NSURL fileURLWithPath:weakSegment.localUrl];
                                                        }
                                                completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                        [self _dealFinishOrFailedSegment:segment error:error];
                                                }];
        self.task = task;
    }
    
    else
    {
        NSURL *url = [NSURL URLWithString:segment.url];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        
        
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request
                                                                         progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                             
                                                                             
                                                                             if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingUpdateProgress:)])
                                                                             {
                                                                                 [self.delegate m3u8SegmentDownloader:self downloadingUpdateProgress:downloadProgress];
                                                                             }
                                                                             
                                                                             
                                                                         }
                                                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                          return [NSURL fileURLWithPath:weakSegment.localUrl];
                                                                      }
                                                                completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                    
                                                                    [self _dealFinishOrFailedSegment:segment error:error];
                                                                    
                                                                }];
        self.task = task;
    }
    
    [self.task resume];
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingBegin:task:)])
    {
        [self.delegate m3u8SegmentDownloader:self downloadingBegin:segment task:self.task];
    }
}


- (void)_dealFinishOrFailedSegment:(M3U8SegmentInfo *)segment error:(NSError *)error
{
    if (error)
    {
        
        //手动暂停的
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData])
        {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingPause:resumeData:)])
            {
                [self.delegate m3u8SegmentDownloader:self downloadingPause:segment resumeData:resumeData];  
            }
        }
        //下载出现错误
        else
        {
            if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadFailed:)])
            {
                [self.delegate m3u8SegmentDownloader:self downloadFailed:error];
            }
        }

        
    }
    else//finish
    {
        if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingFinished:)])
        {
            [self.delegate m3u8SegmentDownloader:self downloadingFinished:segment];
        }
    }
}


- (void)pauseDownload
{
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        /*
        if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingPause:resumeData:)])
        {
            [self.delegate m3u8SegmentDownloader:self downloadingPause:self.segment resumeData:resumeData];
        }
         */
        
    }];
}



























@end
