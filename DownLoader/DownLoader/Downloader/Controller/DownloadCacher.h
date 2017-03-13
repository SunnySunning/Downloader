//
//  DownloadCacher.h
//  DownLoader
//
//  Created by bfec on 17/2/15.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"
#import "FMDB.h"

@interface DownloadCacher : NSObject

@property (nonatomic,strong) FMDatabaseQueue *dbQueue;

+ (id)shareInstance;
- (DownloadStatus)queryDownloadStatusByModel:(DownloadModel *)downloadModel;
- (void)insertDownloadModel:(DownloadModel *)downloadModel;
- (void)updateDownloadModel:(DownloadModel *)downloadModel;
- (void)deleteDownloadModel:(DownloadModel *)downloadModel;
- (void)deleteDownloadModels:(NSArray *)downloadModels;
- (DownloadModel *)queryTopWaitingDownloadModel;
- (void)getNewFromCacherWithModel:(DownloadModel *)downloadModel;
- (NSArray *)startAllDownloadModels;
- (NSArray *)pauseAllDownloadModels;
- (void)initializeDownloadModelFromDBCahcher:(DownloadModel *)downloadModel;
- (BOOL)checkIsExistDownloading;

@end
