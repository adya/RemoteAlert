#import "SilentChecker.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation SilentChecker
+(BOOL) muteSwitchEnabled {
    
#if TARGET_IPHONE_SIMULATOR
    // set to NO in simulator. Code causes crashes for some reason.
    return NO;
#endif
    
    // switch to Ambient to detect the switch
    AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
    [sharedSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
   // AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    [sharedSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    return (CFStringGetLength(state) <= 0);
}
@end
