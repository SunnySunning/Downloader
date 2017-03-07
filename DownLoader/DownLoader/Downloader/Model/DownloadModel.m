//
//  DownloadModel.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadModel.h"
#import "DownloadCacher.h"
#import <UIKit/UIKit.h>

@implementation DownloadModel

- (id)init
{
    if (self = [super init])
    {
        self.status = DownloadNotExist;
        self.resumeData = nil;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[url = %@,\n name = %@,\n status = %d,\n percent = %f]", self.url,self.name,self.status,self.downloadPercent];
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    if ([url containsString:@".m3u8"])
    {
        _isM3u8Url = YES;
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[DownloadModel class]])
    {
        DownloadModel *tempModel = (DownloadModel *)object;
        if ([self.url isEqualToString:tempModel.url])
        {
            self.downloadPercent = tempModel.downloadPercent;
            self.status = tempModel.status;
            self.resumeData = tempModel.resumeData;
            return YES;
        }
    }
    return NO;
}





















@end
