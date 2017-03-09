//
//  DownloadManager+Utils.h
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager (Utils)

+ (void)postNotification:(NSString *)notificationName andObject:(id)object;
+ (NSString *)getMP4LocalUrlWithVideoUrl:(NSString *)videoUrl;
+ (NSString *)getM3U8LocalUrlWithVideoUrl:(NSString *)videoUrl;

@end
