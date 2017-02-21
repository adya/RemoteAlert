import AudioToolbox
import AVFoundation

class SilentChecker {
    
    private var startTime : NSDate?
    private var completion : ((Bool) -> Void)?
    private var soundId : SystemSoundID = 0
    
    var debugDelegate : DebugDelegate?
    
    init() {
        if let url = NSBundle.mainBundle().URLForResource("silence", withExtension: "mp3") {
            var soundId : SystemSoundID = 0
            let userData = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
            AudioServicesCreateSystemSoundID(url, &soundId)
            if soundId > 0 {
                self.soundId = soundId
                AudioServicesAddSystemSoundCompletion(soundId, CFRunLoopGetMain(), kCFRunLoopDefaultMode, { soundId, data in
                  let me = unsafeBitCast(data, SilentChecker.self)
                    me.completed()
                }, userData)
            }
        } else {
            soundId = 0
            print("Failed!")
        }
    }
    
    func check(completion : (Bool) -> Void) {
        self.completion = completion
        let switched = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        debugDelegate?.debug(self, hasDebugInfo: "Audio \(switched != nil ? "has been switched" : "has not been switched") to ambient", withTimestamp: NSDate())
        if let startTime = startTime {
            let now = NSDate()
            if now.timeIntervalSinceDate(startTime) > 1 {
                playSilentSound()
			}else{
				let switchedBack = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
                debugDelegate?.debug(self, hasDebugInfo: "Audio \(switchedBack != nil ? "has been switched" : "has not been switched") to playback", withTimestamp: NSDate())
				completion(false)
			}
        } else {
            playSilentSound()
        }
    }
    
    private func playSilentSound() {
        debugDelegate?.debug(self, hasDebugInfo: "Checking silence mode...", withTimestamp: NSDate())
        startTime = NSDate()
        AudioServicesPlayAlertSound(soundId)
    }
    
    private func completed() {
        let now = NSDate()
        let interval = startTime.flatMap{now.timeIntervalSinceDate($0)} ?? 0
        let threshold = 0.5
        let muted = interval <= threshold
        debugDelegate?.debug(self, hasDebugInfo: "Check done in \(interval) seconds (threshold is \(threshold)) - device \(muted ? "silenced" : "ringing")", withTimestamp: NSDate())
        let switched = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
        debugDelegate?.debug(self, hasDebugInfo: "Audio \(switched != nil ? "has been switched" : "has not been switched") to playback", withTimestamp: NSDate())
        completion?(muted)
    }
    
    deinit {
        
    }
}