import AudioToolbox
import AVFoundation

class SilentChecker {
    
    private var startTime : NSDate?
    private var completion : ((Bool) -> Void)?
    private var soundId : SystemSoundID = 0
    
    init() {
        if let url = NSBundle.mainBundle().URLForResource("silence", withExtension: "mp3") {
            var soundId : SystemSoundID = 0
            let userData = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
            let error = AudioServicesCreateSystemSoundID(url, &soundId)
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
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        if let startTime = startTime {
            let now = NSDate()
            if now.timeIntervalSinceDate(startTime) > 1 {
                playSilentSound()
            }
            
        } else {
            playSilentSound()
        }
    }
    
    private func playSilentSound() {
        startTime = NSDate()
        AudioServicesPlayAlertSound(soundId)
    }
    
    private func completed() {
        let now = NSDate()
        let interval = startTime.flatMap{now.timeIntervalSinceDate($0)} ?? 0
        let muted = interval <= 0.1
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        completion?(muted)
    }
    
    deinit {
        
    }
}