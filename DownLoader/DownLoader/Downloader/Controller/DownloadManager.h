//
//  DownloadManager.h
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"
#import "AFURLSessionManager.h"
#import "DownloadCacher.h"

#define DownloadingUpdateNotification @"DownloadingUpdateNotification"
#define DownloadBeginNotification @"DownloadBeginNotification"
#define DownloadFinishNotification @"DownloadFinishNotification"
#define DownloadFailedNotification @"DownloadFailedNotification"
#define UIDeviceBatteryLowPowerNotification @"UIDeviceBatteryLowPowerNotification"

@interface DownloadManager : NSObject

@property (nonatomic,strong) AFURLSessionManager *urlSession;
@property (nonatomic,strong) DownloadCacher *downloadCacher;
@property (nonatomic,strong) NSMutableArray *downloadQueue;

+ (id)shareInstance;
- (void)dealDownloadModel:(DownloadModel *)downloadModel;
- (void)addDownloadModel:(DownloadModel *)downloadModel;
- (void)pauseDownloadModel:(DownloadModel *)downloadModel;
- (void)deleteDownloadModelArr:(NSArray *)downloadArr;
- (void)startAllDownload;
- (void)pauseAllDownload;
+ (NSString *)getLocalUrlWithVideoUrl:(NSString *)videoUrl;
- (void)initializeDownloadModelFromDBCahcher:(DownloadModel *)downloadModel;

- (void)_tryToOpenNewDownloadTask;
- (void)_postNotification:(NSString *)notificationName andObject:(id)object;
- (void)dealDownloadFinishedOrFailedWithError:(NSError *)error andDownloadModel:(DownloadModel *)downloadModel;

@end
