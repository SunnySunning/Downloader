//
//  ViewController.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "ViewController.h"
#import "DownloadManager.h"
#import "DownloadCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *downloadModels;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self _addObserver];
    UIBarButtonItem *beginItem = [[UIBarButtonItem alloc] initWithTitle:@"初始化" style:UIBarButtonItemStylePlain target:self action:@selector(_begin:)];
    self.navigationItem.leftBarButtonItem = beginItem;
    
    /*
    DownloadModel *downloadModel = [[DownloadModel alloc] init];
    downloadModel.name = @"111";
    downloadModel.url = @"http://video.lincoo.net/1073ht/video/20160425/160425162023244113619/160425162023244113619.m3u8";
    //m3u8格式的视频 必须知道大小 下载进度才会计算出来
    downloadModel.videoSize = 178725454;
    */

    DownloadModel *downloadModel01 = [[DownloadModel alloc] init];
    downloadModel01.name = @"222";
    downloadModel01.url = @"http://video.lincoo.net/1073ht/video/20160323/z160323114420432126520.mp4";
    
    DownloadModel *downloadModel001 = [[DownloadModel alloc] init];
    downloadModel001.name = @"333";
    downloadModel001.url = @"http://video.lincoo.net/1056htcfsy/video/20160309/160309235012828162609.mp4";

    
    self.downloadModels = [NSMutableArray arrayWithArray:@[downloadModel01,downloadModel001]];
    
}


- (void)_begin:(UIBarButtonItem *)beginItem
{
    beginItem.enabled = NO;
    for (DownloadModel *downloadModel in self.downloadModels)
    {
        [[DownloadManager shareInstance] dealDownloadModel:downloadModel];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
    DownloadModel *model = [self.downloadModels objectAtIndex:indexPath.row];
    [cell updateModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DownloadModel *tempModel = [self.downloadModels objectAtIndex:indexPath.row];
    [[DownloadManager shareInstance] dealDownloadModel:tempModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak ViewController *weakS = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DownloadModel *model = [weakS.downloadModels objectAtIndex:indexPath.row];
        [[DownloadManager shareInstance] deleteDownloadModelArr:@[model]];
        [weakS.downloadModels removeObject:model];
        [weakS.tableView reloadData];
    }];
    return @[deleteAction];
}

#pragma mark - 全部开始/暂停
- (IBAction)startAllDownloadBtClick:(UIButton *)bt
{
    [[DownloadManager shareInstance] startAllDownload];
}

- (IBAction)pauseAllDownloadBtClick:(UIButton *)bt
{
    [[DownloadManager shareInstance] pauseAllDownload];
}


#pragma mark - 下载通知
- (void)_updateDownload:(NSNotification *)noti
{
    DownloadModel *tempModel = noti.object;
    DownloadCell *cell = [self _findCellWithModel:tempModel];
    [cell updateModel:tempModel];
}

- (void)_failedDownload:(NSNotification *)noti
{
    DownloadModel *tempModel = noti.object;
    DownloadCell *cell = [self _findCellWithModel:tempModel];
    [cell updateModel:tempModel];
}

- (void)_beginDownload:(NSNotification *)noti
{
    DownloadModel *tempModel = noti.object;
    DownloadCell *cell = [self _findCellWithModel:tempModel];
    [cell updateModel:tempModel];
}

- (void)_finishDownload:(NSNotification *)noti
{
    DownloadModel *tempModel = noti.object;
    DownloadCell *cell = [self _findCellWithModel:tempModel];
    [cell updateModel:tempModel];
}

- (DownloadCell *)_findCellWithModel:(DownloadModel *)tempModel
{
    int index = 0;
    for (DownloadModel *model in self.downloadModels)
    {
        if ([model isEqual:tempModel])
        {
            break;
        }
        index++;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    DownloadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)_addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateDownload:) name:DownloadingUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_beginDownload:) name:DownloadBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_finishDownload:) name:DownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_failedDownload:) name:DownloadFailedNotification object:nil];
}

- (void)_removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadingUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadFailedNotification object:nil];
}

- (void)dealloc
{
    [self _removeObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
