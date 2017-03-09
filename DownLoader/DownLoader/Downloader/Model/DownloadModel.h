//
//  DownloadModel.h
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DownloadNotExist = -1,
    DownloadWating = 0,
    DownloadPause = 1,
    Downloading = 2,
    DownloadFinished = 3,
    DownloadFailed = 4,
}DownloadStatus;

@interface DownloadModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *url;//目前标识一个视频的字段
@property (nonatomic,assign) DownloadStatus status;
@property (nonatomic,assign) double downloadPercent;
@property (nonatomic,copy) NSString *resumeData;
@property (nonatomic,assign) BOOL isM3u8Url;
@property (nonatomic,assign) long long videoSize;
@property (nonatomic,strong) NSError *error;

@end
