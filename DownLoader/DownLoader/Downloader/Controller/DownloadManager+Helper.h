//
//  DownloadManager+Helper.h
//  DownLoader
//
//  Created by bfec on 17/2/17.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager.h"

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

@interface DownloadManager (Helper)

extern NSData *correctResumeData(NSData *data);
extern NSMutableDictionary *getResumeDictionary(NSData *data);
extern NSData * correctRequestData(NSData *data);
- (NSURLSessionDownloadTask *)_downloadTaskWithOriginResumeData:(NSData *)resumeData withDownloadModel:(DownloadModel *)topWaitingModel;

@end
