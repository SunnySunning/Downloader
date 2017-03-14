  //
//  AppDelegate.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "AppDelegate.h"
#import "LocalNotificationManager.h"

@interface AppDelegate ()

@property (nonatomic,assign) NSInteger count;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [LocalNotificationManager initLocalNotification];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.count++;
    NSLog(@"handleEventsForBackgroundURLSession   ===   %ld",(long)self.count);
    self.backgroundSessionCompletionHandler = completionHandler;
}

@end
