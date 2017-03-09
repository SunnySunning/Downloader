//
//  DownloadManager.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager.h"
#import "AppDelegate.h"
#import "DownloadManager+Helper.h"
#import "DownloadManager+Utils.h"
#import "LocalNotificationManager.h"

static DownloadManager *instance;

@interface DownloadManager ()<DownloadManager_M3U8_Delegate>

@property (nonatomic,strong) DownloadModel *downloadingModel;

@end

@implementation DownloadManager

+ (id)shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[DownloadManager alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        NSURLSessionConfiguration *scf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"nsurlsession_download_identifier"];
        self.urlSession = [[AFURLSessionManager alloc] initWithSessionConfiguration:scf];
        self.downloadCacher = [DownloadCacher shareInstance];
        [self _checkOrCreateDownloadFolder];
        [self.urlSession setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (appDelegate.backgroundSessionCompletionHandler)
            {
                appDelegate.backgroundSessionCompletionHandler();
                appDelegate.backgroundSessionCompletionHandler = nil;
            }
        }];
    }
    return self;
}

- (NSMutableArray *)downloadQueue
{
    if (!_downloadQueue)
    {
        _downloadQueue = [NSMutableArray array];
    }
    return _downloadQueue;
}

- (void)dealDownloadModel:(DownloadModel *)downloadModel
{
    [self initializeDownloadModelFromDBCahcher:downloadModel];
    if (downloadModel.isM3u8Url)
    {
        [self _dealDownload_M3U8:downloadModel];
    }
    else
    {
        [self _dealDownload_MP4:downloadModel];
    }
}

- (void)_dealDownload_MP4:(DownloadModel *)downloadModel
{
    DownloadStatus status = downloadModel.status;
    switch (status) {
        case DownloadNotExist:
            [self addDownloadModel:downloadModel];
            break;
            
        case Downloading:
        {
            [self pauseDownloadModel:downloadModel];
            break;
        }
            
        case DownloadWating:
        {
            downloadModel.status = DownloadPause;
            [self _changeStatusWithModel:downloadModel];
            break;
        }
            
        case DownloadPause:
        case DownloadFailed:
        {
            downloadModel.status = DownloadWating;
            [self _changeStatusWithModel:downloadModel];
            break;
        }
            
        case DownloadFinished:
            break;
            
        default:
            break;
    }
    [self _tryToOpenNewDownloadTask];
}

- (void)_dealDownload_M3U8:(DownloadModel *)downloadModel
{
    [DownloadManager_M3U8 shareInstance].delegate = self;
    [DownloadManager_M3U8 shareInstance].downloadCacher = self.downloadCacher;
    [DownloadManager_M3U8 shareInstance].urlSession = self.urlSession;
    [[DownloadManager_M3U8 shareInstance] dealWithModel:downloadModel];
}

- (void)addDownloadModel:(DownloadModel *)downloadModel
{
    downloadModel.status = DownloadWating;
    [self.downloadCacher insertDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)pauseDownloadModel:(DownloadModel *)downloadModel
{
    if ([self.downloadQueue count] > 0)
    {
        NSURLSessionDownloadTask *task = [self.downloadQueue firstObject];
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            downloadModel.resumeData = resumeDataStr;
            downloadModel.status = DownloadPause;
            [self.downloadCacher updateDownloadModel:downloadModel];
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadQueue removeAllObjects];
            });
            */
            @synchronized (self)
            {
                [self.downloadQueue removeAllObjects];
            }
        }];
    }
}

- (void)_changeStatusWithModel:(DownloadModel *)downloadModel
{
    [self.downloadCacher updateDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)deleteDownloadModelArr:(NSArray *)downloadArr
{
    if ([downloadArr containsObject:_downloadingModel])
    {
        NSURLSessionDownloadTask *task = [self.downloadQueue firstObject];
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [self _deleteTmpFileWithResumeData:resumeData];
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadQueue removeAllObjects];
                _downloadingModel = nil;
            });
             */
            @synchronized (self)
            {
                [self.downloadQueue removeAllObjects];
                _downloadingModel = nil;
            }
        }];
    }
    [self.downloadCacher deleteDownloadModels:downloadArr];
    [self _tryToOpenNewDownloadTask];
}

- (void)_deleteTmpFileWithResumeData:(NSData *)resumeData
{
    NSError *error = nil;
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:resumeData options:0 format:&format error:&error];
    if (!error)
    {
        NSString *tmpPath = [dict valueForKey:@"NSURLSessionResumeInfoTempFileName"];
        tmpPath = [NSString stringWithFormat:@"%@/tmp/%@",NSHomeDirectory(),tmpPath];
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmpPath];
        if (fileExist)
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&error];
            if (!error)
            {
                NSLog(@"删除无用的临时文件成功!");
            }
        }
    }
    
}


- (void)startAllDownload
{
    NSArray *arr = [self.downloadCacher startAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [DownloadManager postNotification:DownloadingUpdateNotification andObject:model];
    }
    [self _tryToOpenNewDownloadTask];
}

- (void)pauseAllDownload
{
    [self pauseDownloadModel:_downloadingModel];
    NSArray *arr = [self.downloadCacher pauseAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [DownloadManager postNotification:DownloadingUpdateNotification andObject:model];
    }
}

- (void)_tryToOpenNewDownloadTask
{
    if ([self.downloadQueue count] > 0)//有一个正在下载的task 返回
        return;
    DownloadModel *topWaitingModel = [self.downloadCacher queryTopWaitingDownloadModel];
    if (!topWaitingModel)
    {
        NSLog(@"not find waiting model...");
    }
    else
    {
        topWaitingModel.status = Downloading;
        [self.downloadCacher updateDownloadModel:topWaitingModel];
        _downloadingModel = topWaitingModel;
        
        if (topWaitingModel.isM3u8Url)
        {
            [[DownloadManager_M3U8 shareInstance] m3u8Downloading:topWaitingModel];
        }
        else
        {
            [self _mp4Downloading:topWaitingModel];
        }
    }
}

- (void)_mp4Downloading:(DownloadModel *)downloadModel
{
    if (downloadModel.resumeData)
    {
        NSData *resumeData = [downloadModel.resumeData dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDownloadTask *task = [self _downloadTaskWithOriginResumeData:resumeData withDownloadModel:downloadModel];
        [self.downloadQueue addObject:task];
        [task resume];
    }
    else
    {
        NSURLRequest *rq = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadModel.url]];
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:rq progress:^(NSProgress * _Nonnull downloadProgress) {
            
            downloadModel.downloadPercent = downloadProgress.completedUnitCount / (downloadProgress.totalUnitCount * 1.0);
            [self.downloadCacher updateDownloadModel:downloadModel];
            [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:[DownloadManager getMP4LocalUrlWithVideoUrl:downloadModel.url]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            [self.downloadQueue removeLastObject];
            [self _tryToOpenNewDownloadTask];
            [self dealDownloadFinishedOrFailedWithError:error andDownloadModel:downloadModel];
            
        }];
        [self.downloadQueue addObject:task];
        [task resume];
    }
    [DownloadManager postNotification:DownloadBeginNotification andObject:downloadModel];
}



- (void)_checkOrCreateDownloadFolder
{
    NSString *downloadFolderPath = [NSString stringWithFormat:@"%@/download",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    BOOL isDirectory = YES;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:downloadFolderPath isDirectory:&isDirectory];
    if (!exist)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            NSLog(@"create downloadFolderPath failed...");
        }
        else
        {
            NSLog(@"create downloadFolderPath successful...");
        }
    }
}

- (void)dealDownloadFinishedOrFailedWithError:(NSError *)error andDownloadModel:(DownloadModel *)downloadModel
{
    if (error)
    {
        //手动暂停的
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData])
        {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            downloadModel.resumeData = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            downloadModel.status = DownloadPause;
            [self.downloadCacher updateDownloadModel:downloadModel];
            
            [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载暂停",downloadModel.name]];
            });
        }
        //下载出现错误
        else
        {
            downloadModel.status = DownloadFailed;
            [self.downloadCacher updateDownloadModel:downloadModel];

            downloadModel.error = error;
            [DownloadManager postNotification:DownloadFailedNotification andObject:downloadModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载出现错误",downloadModel.name]];
            });
        }
        
    }
    //下载完成
    else
    {
        downloadModel.status = DownloadFinished;
        downloadModel.downloadPercent = 1.0;
        [self.downloadCacher updateDownloadModel:downloadModel];

        [DownloadManager postNotification:DownloadFinishNotification andObject:downloadModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载完成",downloadModel.name]];
        });
    }
}




- (void)initializeDownloadModelFromDBCahcher:(DownloadModel *)downloadModel
{
    [[DownloadCacher shareInstance] initializeDownloadModelFromDBCahcher:downloadModel];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}




#pragma mark - DownloadManager_M3U8_Delegate

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader beginDownload:(DownloadModel *)downloadModel segment:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task
{
    [self.downloadQueue removeLastObject];
    [self.downloadQueue addObject:task];
    self.downloadingModel = downloadModel;
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader updateDownload:(DownloadModel *)downloadModel progress:(CGFloat)progress
{
    downloadModel.downloadPercent = progress;
    [self.downloadCacher updateDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader dealModelFinished:(DownloadModel *)downloadModel
{
    [self _tryToOpenNewDownloadTask];
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader analyseFailed:(DownloadModel *)downloadModel
{
    [DownloadManager postNotification:DownloadM3U8AnalyseFailedNotification andObject:downloadModel];
}

















@end
