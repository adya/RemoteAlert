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

void MuteCheckCompletionProc(SystemSoundID ssID, void* clientData);

@interface MuteChecker ()
@property (nonatomic,assign) SystemSoundID soundId;
@property (strong) MuteCheckCompletionHandler completionBlk;
@property (nonatomic, strong)NSDate *startTime;
-(void)completed;
@end

void MuteCheckCompletionProc(SystemSoundID ssID, void* clientData){
    MuteChecker *obj = (__bridge MuteChecker *)clientData;
    [obj completed];
}

@implementation MuteChecker

-(void)playMuteSound
{
    self.startTime = [NSDate date];
    AudioServicesPlaySystemSound(self.soundId);
}

-(void)completed
{
    NSDate *now = [NSDate date];
    NSTimeInterval t = [now timeIntervalSinceDate:self.startTime];
    BOOL muted = (t > 0.1)? NO : YES;
    AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
    [sharedSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.completionBlk(t, muted);
}

-(void)check {
    AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
    [sharedSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    if (self.startTime == nil) {
        [self playMuteSound];
    } else {
        NSDate *now = [NSDate date];
        NSTimeInterval lastCheck = [now timeIntervalSinceDate:self.startTime];
        if (lastCheck > 1) {    //prevent checking interval shorter then the sound length
            [self playMuteSound];
        }
    }
}

- (instancetype)initWithCompletionBlk:(MuteCheckCompletionHandler)completionBlk
{
    self = [self init];
    if (self) {
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"MuteChecker" withExtension:@"caf"];
        if (AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_soundId) == kAudioServicesNoError){
            AudioServicesAddSystemSoundCompletion(self.soundId, CFRunLoopGetMain(), kCFRunLoopDefaultMode, MuteCheckCompletionProc,(__bridge void *)(self));
            UInt32 yes = 1;
            AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(_soundId),&_soundId,sizeof(yes), &yes);
            self.completionBlk = completionBlk;
        } else {
            NSLog(@"error setting up Sound ID");
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.soundId != -1){
        AudioServicesRemoveSystemSoundCompletion(self.soundId);
        AudioServicesDisposeSystemSoundID(self.soundId);
    }
}

@end
