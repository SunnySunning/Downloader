//
//  DownloadManager+UIDevieBattery_Memory.h
//  DownLoader
//
//  Created by bfec on 17/3/7.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager (UIDevieBattery_Memory)

+ (void)enableMoniterDeviceBattery_Memory:(BOOL)enabled;
- (BOOL)isMemoryEnoughDownloadNextFile:(long)fileSize;

@end
