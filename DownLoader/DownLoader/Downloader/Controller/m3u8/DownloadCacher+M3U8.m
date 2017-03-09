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
        if ([db open])
        {
            NSLog(@"open or create db successful...");
            
            NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,videoUrl text,tsVideoUrl text,m3u8AlreadyDownloadSize integer,tsDownloadTSIndex integer)",M3U8Table];
            BOOL createResult = [db executeUpdate:createSql];
            if (createResult)
            {
                NSLog(@"create downloadCacherTable successful...");
            }
            else
            {
                NSLog(@"uncreate downloadCacherTable...");
            }
        }
        else
        {
            NSLog(@"unopen or uncreate db...");
        }
    }];
}

@end
