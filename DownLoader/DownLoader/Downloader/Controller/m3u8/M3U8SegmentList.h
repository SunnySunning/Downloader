//
//  M3U8SegmentList.h
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfo.h"

@interface M3U8SegmentList : NSObject

@property (nonatomic,strong) NSMutableArray *segments;
@property (nonatomic,assign) double totalDurations;
@property (nonatomic,copy) NSString *videoUrl;

- (id)initWithSegments:(NSMutableArray *)segments;
- (M3U8SegmentInfo *)getSegmentByIndex:(int)index;

@end
