//
//  DownloadCell.m
//  DownLoader
//
//  Created by bfec on 17/3/6.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadCell.h"

@interface DownloadCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation DownloadCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateModel:(DownloadModel *)downloadModel
{
    self.nameLabel.text = downloadModel.name;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f",downloadModel.downloadPercent];
    NSString *statusStr = nil;
    switch (downloadModel.status)
    {
        case DownloadWating:
            statusStr = @"等待下载";
            break;
            
        case DownloadPause:
            statusStr = @"暂停下载";
            break;
            
        case Downloading:
            statusStr = @"正在下载";
            break;
            
        case DownloadFinished:
            statusStr = @"下载完成";
            break;
            
        case DownloadFailed:
            statusStr = @"下载失败,请删除后重新添加!";
            break;
            
        default:
            break;
    }
    
    if (downloadModel.status == DownloadFailed)
    {
        NSMutableAttributedString *statusAttrStr = [[NSMutableAttributedString alloc] initWithString:statusStr attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        self.statusLabel.attributedText = statusAttrStr;
    }
    else
    {
        self.statusLabel.text = statusStr;
    }
}

@end
