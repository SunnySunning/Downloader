//
//  DownloadManager+Helper.m
//  DownLoader
//
//  Created by bfec on 17/2/17.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager+Helper.h"


static NSData * correctRequestData(NSData *data) {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

static NSMutableDictionary *getResumeDictionary(NSData *data) {
    NSMutableDictionary *iresumeDictionary = nil;
    if (IS_IOS10ORLATER) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
            if (root == nil) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch(NSException *exception) {
            
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
    }
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

static NSData *correctResumeData(NSData *data) {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    if (data == nil) {
        return  nil;
    }
    NSMutableDictionary *resumeDictionary = getResumeDictionary(data);
    if (resumeDictionary == nil) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] = correctRequestData(resumeDictionary[kResumeCurrentRequest]);
    resumeDictionary[kResumeOriginalRequest] = correctRequestData(resumeDictionary[kResumeOriginalRequest]);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}


@implementation DownloadManager (Helper)

- (NSURLSessionDownloadTask *)_downloadTaskWithOriginResumeData:(NSData *)resumeData withDownloadModel:(DownloadModel *)topWaitingModel
{
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    NSData *cData = correctResumeData(resumeData);
    cData = cData ? cData:resumeData;
    
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithResumeData:cData progress:^(NSProgress * _Nonnull downloadProgress) {
        
        topWaitingModel.downloadPercent = downloadProgress.completedUnitCount / (downloadProgress.totalUnitCount * 1.0);
        [self.downloadCacher updateDownloadModel:topWaitingModel];
        [self _postNotification:DownloadingUpdateNotification andObject:topWaitingModel];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:[DownloadManager getLocalUrlWithVideoUrl:topWaitingModel.url]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        @synchronized (self)
        {
            [self.downloadQueue removeLastObject];
        }
        [self _tryToOpenNewDownloadTask];
        [self dealDownloadFinishedOrFailedWithError:error andDownloadModel:topWaitingModel];
        
    }];
    
    NSMutableDictionary *resumeDic = getResumeDictionary(cData);
    if (resumeDic)
    {
        if (task.originalRequest == nil)
        {
            NSData *originalReqData = resumeDic[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData];
            if (originalRequest)
            {
                [task setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (task.currentRequest == nil)
        {
            NSData *currentReqData = resumeDic[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest)
            {
                [task setValue:currentRequest forKey:@"currentRequest"];
            }
        }
    }
    return task;
}

@end
