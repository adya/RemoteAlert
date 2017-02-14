#import <Foundation/Foundation.h>

@class UIApplication;
@class UILocalNotification;

typedef void (^TSNotificationBlock)(UILocalNotification* notification);
typedef BOOL (^TSNotificationValidatingBlock)(UILocalNotification* notification);

@interface TSNotificationManager : NSObject

// put this in the App Delegate appropriate method
+ (void) application:(UIApplication *) application didReceiveLocalNotification:(UILocalNotification *) notification;
+ (BOOL) application:(UIApplication *) application didFinishLaunchingWithOptions:(NSDictionary *) launchOptions;
+ (void) applicationWillTerminate:(UIApplication *) application;
+ (void) applicationDidEnterBackground:(UIApplication *)application;
+ (void) applicationWillEnterForeground:(UIApplication *)application;


+ (NSUInteger) scheduledNotificationsCount;

+(void) setNotificationsEnabled:(BOOL) isEnabled;
+(BOOL) isNotificationsEnabled;
+(void) setHandleNotificationsEnabled:(BOOL) isEnabled;
+(BOOL) isHandleNotificationsEnabled;

/// block should return YES if notification is valid, otherwise - NO.
+ (void) invalidateStoredNotificationsWithBlock:(TSNotificationValidatingBlock) block;

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage withHandler:(TSNotificationBlock) handler on:(NSDate*) date;

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage andUserInfo:(NSDictionary*) userInfo withHandler:(TSNotificationBlock) handler on:(NSDate*) date;

+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage withHandler:(TSNotificationBlock) handler on:(NSDate*) date withTimeZone:(NSTimeZone*) timeZone;


+ (void) scheduleNotificationWithMessage:(NSString*) notificationMessage andUserInfo:(NSDictionary*) userInfo withHandler:(TSNotificationBlock) handler on:(NSDate*) date withTimeZone:(NSTimeZone*) timeZone;

@end
