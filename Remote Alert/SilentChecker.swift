import AudioToolbox
import AVFoundation

class SilentChecker {
    
    fileprivate var startTime : Date?
    fileprivate var completion : ((Bool) -> Void)?
    fileprivate var soundId : SystemSoundID = 0
    
    var debugDelegate : DebugDelegate?
    
    init() {
        if let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") {
            var soundId : SystemSoundID = 0
            let userData = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
            if soundId > 0 {
                self.soundId = soundId
                AudioServicesAddSystemSoundCompletion(soundId, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue, { soundId, data in
                  let me = unsafeBitCast(data, to: SilentChecker.self)
                    me.completed()
                }, userData)
            }
        } else {
            soundId = 0
            print("Failed!")
        }
    }
    
    func check(_ completion : @escaping (Bool) -> Void) {
        self.completion = completion
        let switched = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        debugDelegate?.debug(self, hasDebugInfo: "Audio \(switched != nil ? "has been switched" : "has not been switched") to ambient", withTimestamp: Date())
        if let startTime = startTime {
            let now = Date()
            if now.timeIntervalSince(startTime) > 1 {
                playSilentSound()
			}else{
				let switchedBack = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
                debugDelegate?.debug(self, hasDebugInfo: "Audio \(switchedBack != nil ? "has been switched" : "has not been switched") to playback", withTimestamp: Date())
				completion(false)
			}
        } else {
            playSilentSound()
        }
    }
    
    fileprivate func playSilentSound() {
        debugDelegate?.debug(self, hasDebugInfo: "Checking silence mode...", withTimestamp: Date())
        startTime = Date()
        AudioServicesPlayAlertSound(soundId)
    }
    
    fileprivate func completed() {
        let now = Date()
        let interval = startTime.flatMap{now.timeIntervalSince($0)} ?? 0
        let threshold = 0.8 // against 1.16 seconds of whole audio file.
        let muted = interval <= threshold
        debugDelegate?.debug(self, hasDebugInfo: "Check done in \(interval) seconds (threshold is \(threshold)) - device \(muted ? "silenced" : "ringing")", withTimestamp: Date())
        let switched = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        debugDelegate?.debug(self, hasDebugInfo: "Audio \(switched != nil ? "has been switched" : "has not been switched") to playback", withTimestamp: Date())
        completion?(muted)
    }
    
    deinit {
        
    }
}
