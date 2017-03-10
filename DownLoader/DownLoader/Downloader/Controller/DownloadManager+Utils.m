//
//  DownloadManager+Utils.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager+Utils.h"

@implementation DownloadManager (Utils)

+ (void)postNotification:(NSString *)notificationName andObject:(id)object
{
    if (notificationName == nil || [notificationName isEqualToString:@""])
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
    });
}

+ (NSString *)getMP4LocalUrlWithVideoUrl:(NSString *)videoUrl
{
    if (videoUrl == nil || [videoUrl isEqualToString:@""])
    {
        return nil;
    }
    else
    {
        if ([videoUrl length] > 7 && [videoUrl containsString:@"http://"])
        {
            NSString *subStr = [videoUrl substringFromIndex:7];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            subStr = [@"download" stringByAppendingPathComponent:subStr];
            subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
            return subStr;
        }
        return nil;
    }
}

+ (NSString *)getM3U8LocalUrlWithVideoUrl:(NSString *)videoUrl
{
    NSString *m3u8Path = [self getMP4LocalUrlWithVideoUrl:videoUrl];
    m3u8Path = [m3u8Path stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    BOOL isDirectory = YES;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:m3u8Path isDirectory:&isDirectory];
    if (!exist)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:m3u8Path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!error)
        {
            return m3u8Path;
        }
    }
    else
    {
        return m3u8Path;
    }
    return nil;
}
























@end
