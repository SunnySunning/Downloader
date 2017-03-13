//
//  M3U8SegmentDownloader+Helper.m
//  DownLoader
//
//  Created by bfec on 17/3/13.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentDownloader+Helper.h"
#import "DownloadManager+Helper.h"

@implementation M3U8SegmentDownloader (Helper)

- (NSURLSessionDownloadTask *)_downloadTaskWithOriginResumeData:(NSData *)resumeData withSegment:(M3U8SegmentInfo *)segment
{
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    NSData *cData = correctResumeData(resumeData);
    cData = cData ? cData:resumeData;
    
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithResumeData:cData progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if ([self.delegate respondsToSelector:@selector(m3u8SegmentDownloader:downloadingUpdateProgress:)])
        {
            [self.delegate m3u8SegmentDownloader:self downloadingUpdateProgress:downloadProgress];
        }

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:segment.localUrl];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self _dealFinishOrFailedSegment:segment error:error];
    }];
    
    NSMutableDictionary *resumeDic = getResumeDictionary(cData);
    if (resumeDic)
    {
        if (task.originalRequest == nil)
        {
            NSData *originalReqData = resumeDic[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData];
            if (originalRequest)
            {
                [task setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (task.currentRequest == nil)
        {
            NSData *currentReqData = resumeDic[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest)
            {
                [task setValue:currentRequest forKey:@"currentRequest"];
            }
        }
    }
    return task;
}


@end
