//
//  M3U8SegmentDownloader.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentDownloader.h"
#import "M3U8SegmentDownloader+Helper.h"

static M3U8SegmentDownloader *instance;

@interface M3U8SegmentDownloader ()

@property (nonatomic,strong) M3U8SegmentInfo *segment;

@end

@implementation M3U8SegmentDownloader

+ (id)shareInstance
{
    static dispatch_once_t token3;
    dispatch_once(&token3, ^{
        instance = [[M3U8SegmentDownloader alloc] init];
    });
    return instance;
}

- (void)startDownload:(M3U8SegmentInfo *)segment withResumeData:(NSString *)resumeData
{
    NSURLSessionDownloadTask *tmpTask = nil;
    self.segment = segment;
    __weak M3U8SegmentInfo *weakSegment = segment;
    
    NSLog(@"downloadUrl   ===    %@",weakSegment.url);

    /*
    if (![resumeData isEqualToString:@""] && resumeData)
    {
        NSData *resume = [resumeData dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDownloadTask *task = [self _downloadTaskWithOriginResumeData:resume withSegment:segment];
        tmpTask = task;
    }
    
    else
     */
    {
        NSURL *url = [NSURL URLWithString:segment.url];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        
        assert(self.urlSession != nil);
        
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
        tmpTask = task;
    }
    
    [tmpTask resume];
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingBegin:task:)])
    {
        [self.delegate m3u8SegmentDownloader:self downloadingBegin:segment task:tmpTask];
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


- (void)pauseDownloadWithResumeData:(NSData *)resumeData downloadIndex:(NSInteger)index downloadSize:(NSInteger)downloadSize url:(NSString *)url
{
    NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    NSDictionary *m3u8Info = @{@"videoUrl":url,
                               @"m3u8AlreadyDownloadSize":@(downloadSize),
                               @"tsDownloadTSIndex":@(index),
                               @"resumeData":resumeDataStr};
    [self.downloadCacher insertM3U8Record:m3u8Info];
}



























@end
