//
//  DownloadManager_M3U8.h
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"

@interface DownloadManager_M3U8 : NSObject

+ (id)shareInstance;
- (void)dealWithModel:(DownloadModel *)downloadModel;

@end
