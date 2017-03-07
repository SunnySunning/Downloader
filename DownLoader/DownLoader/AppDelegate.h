//
//  AppDelegate.h
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackgroundSessionCompletionHandler)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) BackgroundSessionCompletionHandler backgroundSessionCompletionHandler;

@end

