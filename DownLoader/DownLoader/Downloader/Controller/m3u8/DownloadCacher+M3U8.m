//
//  DownloadCacher+M3U8.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadCacher+M3U8.h"

#define M3U8Table @"m3u8Table"

@implementation DownloadCacher (M3U8)

- (void)createM3U8Table
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        {
            NSLog(@"open or create db successful...");
            
            NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,videoUrl text,m3u8AlreadyDownloadSize integer,tsDownloadTSIndex integer,resumeData text)",M3U8Table];
            BOOL createResult = [db executeUpdate:createSql];
            if (createResult)
            {
                NSLog(@"create m3u8Table successful...");
            }
            else
            {
                NSLog(@"uncreate downloadCacherTable...");
            }
        }
    }];
}

- (void)deleteM3U8Record:(NSString *)m3u8VideoUrl
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE videoUrl = '%@'", M3U8Table, m3u8VideoUrl];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL deleteResult = [db executeUpdate:sql];
        if (deleteResult)
        {
            
        }
        else
        {
            
        }
    }];

}

- (void)insertM3U8Record:(NSDictionary *)m3u8DictInfo
{
    NSDictionary *dict = [self queryM3U8Record:m3u8DictInfo[@"videoUrl"]];
    NSString *sql = nil;
    if ([dict valueForKey:@"videoUrl"])
    {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET m3u8AlreadyDownloadSize = %ld, tsDownloadTSIndex = %ld,resumeData = '%@'  WHERE videoUrl = '%@' ", M3U8Table, [m3u8DictInfo[@"m3u8AlreadyDownloadSize"] longValue],[m3u8DictInfo[@"tsDownloadTSIndex"] longValue],m3u8DictInfo[@"resumeData"], m3u8DictInfo[@"videoUrl"]];
    }
    
    else
    {
        sql = [NSString stringWithFormat:@"INSERT INTO %@(videoUrl,m3u8AlreadyDownloadSize,tsDownloadTSIndex,resumeData) VALUES('%@',%ld,%ld,'%@')", M3U8Table,m3u8DictInfo[@"videoUrl"],[m3u8DictInfo[@"m3u8AlreadyDownloadSize"] longValue],[m3u8DictInfo[@"tsDownloadTSIndex"] longValue],m3u8DictInfo[@"resumeData"]];
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result)
        {
            NSLog(@"INSERT OR UPDATE M3U8Table SUCCESSFUL...");
        }
        else
        {
            NSLog(@"INSERT OR UPDATE M3U8Table FAILED...");
        }
    }];
}

- (NSDictionary *)queryM3U8Record:(NSString *)m3u8VideoUrl
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where videoUrl = '%@'", M3U8Table, m3u8VideoUrl];
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *weakDict = infoDict;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next)
        {
            NSString *videoUrl = [resultSet stringForColumn:@"videoUrl"];
            NSInteger m3u8AlreadyDownloadSize = [resultSet intForColumn:@"m3u8AlreadyDownloadSize"];
            NSInteger tsDownloadTSIndex = [resultSet intForColumn:@"tsDownloadTSIndex"];
            NSString *resumeData = [resultSet stringForColumn:@"resumeData"];
            
            [weakDict setValue:videoUrl forKey:@"videoUrl"];
            [weakDict setValue:@(m3u8AlreadyDownloadSize) forKey:@"m3u8AlreadyDownloadSize"];
            [weakDict setValue:@(tsDownloadTSIndex) forKey:@"tsDownloadTSIndex"];
            [weakDict setValue:resumeData forKey:@"resumeData"];
            break;
        }
        [resultSet close];
    }];
    return weakDict;
}

@end
