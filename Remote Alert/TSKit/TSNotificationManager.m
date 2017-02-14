#import "TSNotificationManager.h"
#import <UIKit/UIKit.h>

#define TS_NOTIFICATIONS_HANDLERS @"TSNotificationsHandlers"

#define KEY_NOTIFICATIONS_ENABLED @"notificationsEnabled"
#define KEY_HANDLE_NOTIFICATIONS_ENABLED @"handleNotificationsEnabled"



@implementation TSNotificationManager{
    NSMutableDictionary* pendingNotifications;
    BOOL notificationsEnabled;
    BOOL handleNotificationsEnabled;
}

+ (instancetype) sharedManager{
    static TSNotificationManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[self alloc] init]; [manager loadSettings]; });
    return manager;
}

+(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        application.applicationIconBadgeNumber = 0;
        [[TSNotificationManager sharedManager] handleReceivedNotification:localNotification];
    }
    
    NSLog(@"Clearing %lu scheduled notifications", (unsigned long)[self scheduledNotificationsCount]);
    [self cancelAllNotifications];
    return YES;
}

+(void) application:(UIApplication*) application didReceiveLocalNotification:(UILocalNotification*) notification {
    application.applicationIconBadgeNumber = 0;
    
    [[TSNotificationManager sharedManager] handleReceivedNotification:notification];
}

+ (void) applicationWillTerminate:(UIApplication *) application{

}

+ (void) applicationDidEnterBackground:(UIApplication *)application{
	
}

+ (void) applicationWillEnterForeground:(UIApplication *)application{
	
}

+ (NSUInteger) scheduledNotificationsCount{
    return [UIApplication sharedApplication].scheduledLocalNotifications.count;
}

+(void) cancelAllNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage withHandler:(TSNotificationBlock) handler on:(NSDate*) date{
    [TSNotificationManager scheduleNotificationWithMessage:notificationMessage andUserInfo:nil withHandler:handler on:date];
}

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage andUserInfo:(NSDictionary*) userInfo withHandler:(TSNotificationBlock) handler on:(NSDate*) date{
    [TSNotificationManager scheduleNotificationWithMessage:notificationMessage andUserInfo:userInfo withHandler:handler on:date withTimeZone:[NSTimeZone defaultTimeZone]];
}

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage withHandler:(TSNotificationBlock) handler on:(NSDate*) date withTimeZone:(NSTimeZone*) timeZone{
	[TSNotificationManager scheduleNotificationWithMessage:notificationMessage andUserInfo:nil withHandler:handler on:date withTimeZone:timeZone];
}

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage andUserInfo:(NSDictionary*) userInfo withHandler:(TSNotificationBlock) handler on:(NSDate*) date withTimeZone:(NSTimeZone*) timeZone{
    [[TSNotificationManager sharedManager] scheduleNotificationWithMessage:notificationMessage andUserInfo:userInfo withHandler:handler on:date withTimeZone:timeZone];
}

+(void) invalidateStoredNotificationsWithBlock:(TSNotificationValidatingBlock)block{
    [[TSNotificationManager sharedManager] invalidateStoredNotificationsWithBlock:block];
}

+(void) setNotificationsEnabled:(BOOL) isEnabled{
    [[TSNotificationManager sharedManager] setNotificationsEnabled:isEnabled];
    
}
+(BOOL) isNotificationsEnabled{
    return [[TSNotificationManager sharedManager] isNotificationsEnabled];
}

+(void) setHandleNotificationsEnabled:(BOOL) isEnabled{
    [[TSNotificationManager sharedManager] setHandleNotificationsEnabled:isEnabled];
}

+(BOOL) isHandleNotificationsEnabled{
    return [[TSNotificationManager sharedManager] isHandleNotificationsEnabled];;
}

-(void) saveSettings{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@(notificationsEnabled) forKey:KEY_NOTIFICATIONS_ENABLED];
    [prefs setObject:@(handleNotificationsEnabled) forKey:KEY_HANDLE_NOTIFICATIONS_ENABLED];
    [prefs synchronize];
    NSLog(@"%@", [prefs dictionaryRepresentation]);
}

-(void) loadSettings{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [prefs dictionaryRepresentation]);
    id obj = [prefs objectForKey:KEY_NOTIFICATIONS_ENABLED];
    notificationsEnabled = (obj ? [obj boolValue] : YES);
    obj = [prefs objectForKey:KEY_HANDLE_NOTIFICATIONS_ENABLED];
    handleNotificationsEnabled = (obj ? [obj boolValue] : YES);
}

-(void) setNotificationsEnabled:(BOOL) isEnabled{
    notificationsEnabled = isEnabled;
    [self saveSettings];
    if (!notificationsEnabled){
        [TSNotificationManager cancelAllNotifications];
        pendingNotifications = nil;
    }
    
}
-(BOOL) isNotificationsEnabled{
    return notificationsEnabled;
}

-(void) setHandleNotificationsEnabled:(BOOL) isEnabled{
    handleNotificationsEnabled = isEnabled;
    [self saveSettings];
}

-(BOOL) isHandleNotificationsEnabled{
    return handleNotificationsEnabled;
}


-(void) handleReceivedNotification:(UILocalNotification*)notification{
    if (!notification || !pendingNotifications) return;
    if (!handleNotificationsEnabled){
        NSLog(@"Notification received, but handling disabled.");
        return;
    }
    NSLog(@"Notification handled: %@", notification);
    TSNotificationBlock handler = [pendingNotifications objectForKey:notification];
    if (handler)
        handler(notification);
    else
        NSLog(@"No handler for notification: %@", notification);
}

-(void) invalidateStoredNotificationsWithBlock:(TSNotificationValidatingBlock)block{
    if (!block || !pendingNotifications) return;
    if (!notificationsEnabled){
        NSLog(@"Notifications disabled.");
        return;
    }
    NSMutableDictionary* updatedNotifications = [NSMutableDictionary new];
    [pendingNotifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (block(key))
            [updatedNotifications setObject:obj forKey:key];
        else
            NSLog(@"Notification removed: %@", key);
    }];
    pendingNotifications = updatedNotifications;
}

-(void) scheduleNotificationWithMessage:(NSString *)notificationMessage andUserInfo:(NSDictionary*) userInfo withHandler:(TSNotificationBlock) handler on:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone{
    if (!notificationsEnabled){
        NSLog(@"Notifications disabled.");
        return;
    }
    if (!pendingNotifications) pendingNotifications = [NSMutableDictionary new];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.alertBody = notificationMessage;
    localNotification.timeZone = timeZone;
    localNotification.userInfo = userInfo;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    if (![pendingNotifications objectForKey:localNotification]){
    [pendingNotifications setObject:handler forKey:localNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSLog(@"Notification scheduled: %@", localNotification);}
    else{
        NSLog(@"Notification already scheduled: %@", localNotification);
    }
}

@end
