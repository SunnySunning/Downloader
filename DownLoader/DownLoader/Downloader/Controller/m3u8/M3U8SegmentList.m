//
//  M3U8SegmentList.m
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentList.h"

@implementation M3U8SegmentList

- (id)initWithSegments:(NSArray *)segments
{
    if (self = [super init])
    {
        self.segments = segments;
    }
    return self;
}

- (M3U8SegmentInfo *)getSegmentByIndex:(int)index
{
    if (index < [self.segments count] && index > 0)
    {
        return [self.segments objectAtIndex:index];
    }
    return nil;
}

@end
