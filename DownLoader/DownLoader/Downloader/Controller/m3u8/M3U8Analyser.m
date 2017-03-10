//
//  M3U8Analyser.m
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#define NSErrorCustomDomain @"NSErrorCustomDomain"

#import "M3U8Analyser.h"
@implementation M3U8Analyser

- (M3U8SegmentList *)analyseVideoUrl:(NSString *)videoUrl error:(NSError *__autoreleasing *)error
{
    if ([videoUrl isEqualToString:@""] || videoUrl == nil)
    {
        NSDictionary *userInfo = @{@"errorDes":@"videoUrl must not nil or empty!"};
        *error = [NSError errorWithDomain:NSErrorCustomDomain code:-111 userInfo:userInfo];
        return nil;
    }
    NSURL *url = [NSURL URLWithString:videoUrl];
    NSError *err = nil;
    NSString *m3u8Str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
        NSDictionary *userInfo = err.userInfo;
        *error = [NSError errorWithDomain:NSErrorCustomDomain code:-222 userInfo:userInfo];
        return nil;
    }
    
    return [self _analyseWithM3U8Str:m3u8Str videoUrl:videoUrl];
}

- (M3U8SegmentList *)_analyseWithM3U8Str:(NSString *)m3u8Str videoUrl:(NSString *)videoUrl
{
    NSString *remainData = m3u8Str;
    NSMutableArray *segments = [NSMutableArray array];
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    NSInteger segmentIndex = 0;
    double totalSeconds = 0;
    while (segmentRange.location != NSNotFound)
    {
        M3U8SegmentInfo *segment = [[M3U8SegmentInfo alloc] init];
        //读取片段时长
        NSRange commaRange = [remainData rangeOfString:@","];
        NSString *value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        totalSeconds+=segment.duration;
        remainData = [remainData substringFromIndex:commaRange.location];
        //读取片段url
        NSRange linkRangeBegin = NSMakeRange([remainData rangeOfString:@","].location + 1, [remainData rangeOfString:@","].length - 1) ;
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        NSString *linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.url = linkurl;
        segment.shortUrl = linkurl;
        segmentIndex++;
        [segments addObject:segment];
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    
    M3U8SegmentList *segmentList = [[M3U8SegmentList alloc] initWithSegments:segments];
    segmentList.totalDurations = totalSeconds;
    segmentList.videoUrl = videoUrl;
    return segmentList;
}


























@end
