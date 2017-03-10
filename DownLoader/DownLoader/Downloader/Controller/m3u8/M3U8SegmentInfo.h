//
//  M3U8SegmentInfo.h
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8SegmentInfo : NSObject

@property (nonatomic,assign) double duration;
@property (nonatomic,copy) NSString *shortUrl;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *localUrl;

@end
