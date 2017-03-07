# Downloader
一 : iOS downloader for app
---
    基于NSURLSession的下载器,mp4/mp3等资源都可以使用,m3u8格式的后续会添加
二 : 核心类介绍
---
	DownloadManager:下载的核心类
	
   	DownloadManager+Helper:兼容iOS10关于NSURLSessionDownloadTask的resumeData的bug
	
   	DownloadManager+UIDeviceBattery_Memory:设备低电量通知与设备硬盘剩余大小是否足够允许继续下载
	
   	DownloadManager+AppWillTerminate:APP被强制关闭,下载器保留状态

   	DownloadCacher:下载条目状态,进度,url等缓存信息的管理类

   	DownloadModel:下载的model类

   	DownloadCell:下载展示的cell类
三 : 核心功能
---
   	支持后台下载

   	支持前后台下载完成的通知

   	支持全部开始,全部暂停功能
四 : 截图
---
	截图请查看demo.png
