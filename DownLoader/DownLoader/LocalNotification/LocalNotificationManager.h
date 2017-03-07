#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// UILocalNotification
// alertBody、alertAction、hasAction和alertLaunchImage是当应用不在运行时，系统处理
// alertBody是一串现实提醒内容的字符串（NSString），如果 alertBody未设置的话，Notification被激发时将不现实提醒。alertAction也是一串字符 （NSString），alertAction的内容将作为提醒中动作按钮上的文字，如果未设置的话，提醒信息中的动作按钮将显示为“View”相对文字 形式。
// alertLaunchImage是在用户点击提醒框中动作按钮（“View”）时，等待应用加载时显示的图片，这个将替代应用原本设置的加载图 片。
// hasAction是一个控制是否在提醒框中显示动作按钮的布尔值，默认值为YES。

// 使用UILocalNotification可以直接把把软件的界面推送出去的办法吗，有的话怎么弄
// 不可以，建议你了解一下本地推送的机制
// 推送的内容限于alertBody（推送显示的字符串）、alertAction（推送的按钮上的文字）、hasAction（是否显示按钮）和alertLaunchImage（图标）
// 推送的界面和控件是固定死的，开发者没有权限自定义

@interface LocalNotificationManager : NSObject
// 发送一条本地通知
+ (void) sendNotification : (NSString*) message fireTime : (NSDate*) fireTime;
// 立即发送一条本地通知
+ (void) sendNotificationNow : (NSString*) message;
// 取消一条本地通知
+ (void) cancelNotification : (UILocalNotification*) localNotify;
// 取消所有本地通知
+ (void) cancelAllLocalNotifications;
// 接收到一条本地通知，进行处理
//+ (void) processNotification : (UILocalNotification*) localNotify;
+ (void) cancelSpecific : (UILocalNotification*) notify;
+ (BOOL) HasNotification : (UILocalNotification*) notify;
+ (void) AddNotification : (UILocalNotification*) notify;
+ (void) RemoveNotification : (UILocalNotification*) notify;
+ (void)showStatusMessage:(NSString *)message;
+ (void) initLocalNotification;

@end