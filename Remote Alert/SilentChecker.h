#import <Foundation/Foundation.h>

@interface SilentChecker : NSObject
    +(BOOL) muteSwitchEnabled;
@end


typedef void (^MuteCheckCompletionHandler)(NSTimeInterval lapse, BOOL muted);

// this class must use with a MuteChecker.caf (a 0.2 sec mute sound) in Bundle
@interface MuteChecker : NSObject
-(instancetype)initWithCompletionBlk:(MuteCheckCompletionHandler)completionBlk;
-(void)check;
@end