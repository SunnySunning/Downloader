//
//  DownloadManager_M3U8.m
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager_M3U8.h"
#import "M3U8Analyser.h"

static DownloadManager_M3U8 *instance;

@interface DownloadManager_M3U8 ()

@property (nonatomic,strong) M3U8Analyser *analyser;
@property (nonatomic,strong) M3U8SegmentList *downloading_m3u8SegmentList;

@end

@implementation DownloadManager_M3U8

+ (id)shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[DownloadManager_M3U8 alloc] init];
    });
    return instance;
}

- (M3U8Analyser *)analyser
{
    if (!_analyser)
    {
        _analyser = [[M3U8Analyser alloc] init];
    }
    return _analyser;
}

- (void)dealWithModel:(DownloadModel *)downloadModel
{
    
}

@end
