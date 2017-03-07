//
//  DownloadManager+UIDevieBattery_Memory.m
//  DownLoader
//
//  Created by bfec on 17/3/7.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager+UIDevieBattery_Memory.h"

@implementation DownloadManager (UIDevieBattery_Memory)

+ (void)enableMoniterDeviceBattery_Memory:(BOOL)enabled
{
    DownloadManager *downloadManager = [DownloadManager shareInstance];
    [downloadManager _moniterDeviceBattery:enabled];
}

- (void)_moniterDeviceBattery:(BOOL)enabled
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:enabled];
    if (enabled)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStateOrLevelChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_batteryStateOrLevelChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }

}

- (void)_batteryStateOrLevelChange:(NSNotification *)noti
{
    UIDevice *device = noti.object;
    
    if (device.batteryState == UIDeviceBatteryStateUnplugged || device.batteryState == UIDeviceBatteryStateUnknown)
    {
        if (device.batteryLevel < 0.2)//未充电电量低于20%
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceBatteryLowPowerNotification object:device];
        }
    }
}

- (BOOL)isMemoryEnoughDownloadNextFile:(long)fileSize
{
    NSDictionary *systemAttributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:NSHomeDirectory()];
    NSString *diskFreeSize = [systemAttributes objectForKey:@"NSFileSystemFreeSize"];
    if (fileSize > [diskFreeSize longLongValue]) {
        return YES;
    }
    return NO;
}


@end
