//
//  AppDelegate.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "AppDelegate.h"
#import "LocalNotificationManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [LocalNotificationManager initLocalNotification];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

@end
