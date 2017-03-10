//
//  DownloadCacher+M3U8.h
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadCacher.h"

@interface DownloadCacher (M3U8)

- (void)createM3U8Table;
- (void)deleteM3U8Record:(NSString *)m3u8VideoUrl;
- (void)insertM3U8Record:(NSDictionary *)m3u8DictInfo;
- (NSDictionary *)queryM3U8Record:(NSString *)m3u8VideoUrl;

@end
