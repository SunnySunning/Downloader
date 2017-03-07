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
#import "LocalNotificationManager.h"

static DownloadManager *instance;

@interface DownloadManager ()

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
    DownloadStatus status = [self.downloadCacher queryDownloadStatusByModel:downloadModel];
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

- (void)addDownloadModel:(DownloadModel *)downloadModel
{
    downloadModel.status = DownloadWating;
    [self.downloadCacher insertDownloadModel:downloadModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:downloadModel];
}

- (void)pauseDownloadModel:(DownloadModel *)downloadModel
{
    if ([self.downloadQueue count] > 0)
    {
        NSURLSessionDownloadTask *task = [self.downloadQueue firstObject];
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            NSLog(@"NSThread  ==  %@",[NSThread currentThread]);
            
            NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            downloadModel.resumeData = resumeDataStr;
            downloadModel.status = DownloadPause;
            [self.downloadCacher updateDownloadModel:downloadModel];
            
#warning 这里会出现潜在的bug
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadQueue removeAllObjects];
            });
            
        }];
    }
}

- (void)_changeStatusWithModel:(DownloadModel *)downloadModel
{
    [self.downloadCacher updateDownloadModel:downloadModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:downloadModel];
}

- (void)deleteDownloadModelArr:(NSArray *)downloadArr
{
    if ([downloadArr containsObject:_downloadingModel])
    {
        NSURLSessionDownloadTask *task = [self.downloadQueue firstObject];
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.downloadQueue removeAllObjects];
                _downloadingModel = nil;
                
            });
        }];
    }
    [self.downloadCacher deleteDownloadModels:downloadArr];
    [self _tryToOpenNewDownloadTask];
}

- (void)startAllDownload
{
    NSArray *arr = [self.downloadCacher startAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:model];
    }
    [self _tryToOpenNewDownloadTask];
}

- (void)pauseAllDownload
{
    [self pauseDownloadModel:_downloadingModel];
    NSArray *arr = [self.downloadCacher pauseAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:model];
    }
}

- (void)_tryToOpenNewDownloadTask
{
    if ([self.downloadQueue count] > 0)//有一个正在下载的 返回
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
        if (topWaitingModel.resumeData)
        {
            NSData *resumeData = [topWaitingModel.resumeData dataUsingEncoding:NSUTF8StringEncoding];
            NSURLSessionDownloadTask *task = [self _downloadTaskWithOriginResumeData:resumeData withDownloadModel:topWaitingModel];
            [self.downloadQueue addObject:task];
            [task resume];
        }
        else
        {
            NSURLRequest *rq = [NSURLRequest requestWithURL:[NSURL URLWithString:topWaitingModel.url]];
            NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:rq progress:^(NSProgress * _Nonnull downloadProgress) {
                
                topWaitingModel.downloadPercent = downloadProgress.completedUnitCount / (downloadProgress.totalUnitCount * 1.0);
                [self.downloadCacher updateDownloadModel:topWaitingModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:topWaitingModel];
                });
                
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                
                return [NSURL fileURLWithPath:[DownloadManager getLocalUrlWithVideoUrl:topWaitingModel.url]];
                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                
                [self.downloadQueue removeLastObject];
                [self _tryToOpenNewDownloadTask];
                [self dealDownloadFinishedOrFailedWithError:error andDownloadModel:topWaitingModel];
                
            }];
            [self.downloadQueue addObject:task];
            [task resume];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadBeginNotification object:topWaitingModel];
    }
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

+ (NSString *)getLocalUrlWithVideoUrl:(NSString *)videoUrl
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DownloadingUpdateNotification object:downloadModel];
                [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载暂停",downloadModel.name]];

            });

        }
        //下载出现错误
        else
        {
            downloadModel.status = DownloadFailed;
            [self.downloadCacher updateDownloadModel:downloadModel];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                downloadModel.error = error;
                [[NSNotificationCenter defaultCenter] postNotificationName:DownloadFailedNotification object:downloadModel];
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

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadFinishNotification object:downloadModel];
            
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





@end
