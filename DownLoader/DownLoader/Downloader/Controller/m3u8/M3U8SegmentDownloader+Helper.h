//
//  M3U8SegmentDownloader+Helper.h
//  DownLoader
//
//  Created by bfec on 17/3/13.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentDownloader.h"

@interface M3U8SegmentDownloader (Helper)

- (NSURLSessionDownloadTask *)_downloadTaskWithOriginResumeData:(NSData *)resumeData withSegment:(M3U8SegmentInfo *)segment;

@end
