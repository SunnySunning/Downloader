//
//  DownloadManager+AppWillTerminate.m
//  DownLoader
//
//  Created by bfec on 17/3/7.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager+AppWillTerminate.h"

@implementation DownloadManager (AppWillTerminate)

+ (void)load
{
    DownloadManager *manager = [DownloadManager shareInstance];
    [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(_appWillTerminateNoti:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)_appWillTerminateNoti:(NSNotification *)noti
{
    [self pauseAllDownload];
}

@end
