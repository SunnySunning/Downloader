#import "LocalNotificationManager.h"
#import <CoreText/CoreText.h>
#import "AppDelegate.h"
#import "UIWindow+CWStatusBarNotification.h"


static int g_nNotificationIndex = 1;

@implementation LocalNotificationManager

/*!
 @method initLocalNotification
 @abstract 初始化本地通知
 @discussion
 @result 无
 */
+ (void) initLocalNotification
{
#ifdef __IPHONE_8_0

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

#else
    
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    
#endif
    
}

// 发送一条本地通知
+ (void) sendNotificationNow : (NSString*) message
{
    [LocalNotificationManager __sendNotifycationNow : message fireTime:[NSDate date]];
}

// 立即发送一条本地通知
+ (void) sendNotification : (NSString*) message  fireTime : (NSDate*) fireTime
{
    [LocalNotificationManager __sendNotifycationNow : message fireTime:fireTime];
}

// 生成本地通知
+ (UILocalNotification*) newLocalNotification : (NSString*) message fireTime : (NSDate*) fireTime
{
       UILocalNotification * notification=[[UILocalNotification alloc] init];
    //5秒后启动
    notification.fireDate = fireTime;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    // NSLog([[NSBundle mainBundle] pathForResource:@"0001" ofType:@"png"]);
    //  notification.alertLaunchImage = path;// [[NSBundle mainBundle] pathForResource:@"0001" ofType:@"png"];
    //显示在icon上的红色圈中的数子
    
    // 特别注意的地方
    // 不设置Badge字段，打开通知中心， 通知条目不删除
    // 如果设置这个字段，每次打开通知中心， 就会删除所有本地通知Item
    // notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    /* 并且这个函数不能添加， 添加后程序打开后删除所有通知
     不实现改函数， 将不会删除本地通知
     
     // 要像保留通知, 必须实现一下两点
     1. Badge字段不能设置
     2. didReceiveLocalNotification不能写
     
    - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iWeibo" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
         [alert show];
         // 图标上的数字减1
         //application.applicationIconBadgeNumber -= 1;
         //[LocalNotificationManager processNotification:notification];
         }
    */

        
    // 设置重复间隔
    notification.repeatInterval = 0;//kCFCalendarUnitDay;
    
    // 设置应用程序右上角的提醒个数
   // notification.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
    
    // notification.repeatInterval = 0;
    notification.hasAction = NO;
    notification.alertAction = @"关闭";
    
    //设置userinfo 方便在之后需要撤销的时候使用
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:g_nNotificationIndex++]forKey:@"key"];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = info;
    
    return notification;
}

// 立即发送本地通知
+ (void) __sendNotifycationNow : (NSString*) message  fireTime : (NSDate*) fireTime
{
    UILocalNotification* notification = [LocalNotificationManager newLocalNotification : message fireTime : fireTime];
    [[UIApplication sharedApplication] presentLocalNotificationNow : notification];
    [LocalNotificationManager showStatusMessage:message];
}

// 取消一条本地通知
+ (void) cancelNotification : (UILocalNotification*) localNotify
{
    [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
}

// 取消所有本地通知
+ (void) cancelAllLocalNotifications
{
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

// 显示状态栏信息
+ (void)showStatusMessage:(NSString *)message
{
     AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window showStatusBarNotification:message forDuration:2.0];
}

+ (void) cancelSpecific : (UILocalNotification*) notify
{
    BOOL exists = [LocalNotificationManager HasNotification:notify];
    
    if (exists)
    {
        [LocalNotificationManager RemoveNotification:notify];
        [[UIApplication sharedApplication] cancelLocalNotification:notify];
        
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0)
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber --;
        }
    }
    else
    {
        [LocalNotificationManager AddNotification:notify];
    }
}

+ (NSMutableDictionary*) GetNotificationFlags
{
    static NSMutableDictionary* items = nil;
    
    @synchronized(self)
    {
        if (items == nil)
            items = [NSMutableDictionary dictionary];
    }
    
    return items;
}

+ (void) AddNotification : (UILocalNotification*) notify
{
    NSDictionary* info = notify.userInfo;
    NSNumber* key = info[@"key"];
    if (key == nil) return;
    NSMutableDictionary* items = [LocalNotificationManager GetNotificationFlags];
    NSNumber* value = items[key];
    if (value != nil) return;
    value = [NSNumber numberWithBool:YES];
    items[key] = value;
}

+ (void) RemoveNotification : (UILocalNotification*) notify
{
    NSDictionary* info = notify.userInfo;
    NSNumber* key = info[@"key"];
    NSMutableDictionary* items = [LocalNotificationManager GetNotificationFlags];
    [items removeObjectForKey:key];
}

+ (BOOL) HasNotification : (UILocalNotification*) notify
{
    NSDictionary* info = notify.userInfo;
    NSNumber* key = info[@"key"];
    NSMutableDictionary* items = [LocalNotificationManager GetNotificationFlags];
    NSNumber* value = items[key];
    if (value == nil) return NO;
    return YES;
}

@end