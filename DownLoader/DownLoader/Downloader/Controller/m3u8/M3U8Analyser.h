//
//  M3U8Analyser.h
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentList.h"
#import "M3U8SegmentInfo.h"

@interface M3U8Analyser : NSObject

- (M3U8SegmentList *)analyseVideoUrl:(NSString *)videoUrl error:(NSError **)error;

@end
