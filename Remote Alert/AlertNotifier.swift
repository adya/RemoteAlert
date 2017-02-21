import UIKit
import AVFoundation
import MediaPlayer

protocol AlertNotifier {
    func notifyAlertsTriggered(alert : [Alert])
    var background : Bool {get set}
    var debugDelegate : DebugDelegate? {get set}
}

class AudioAlertNotifier : AlertNotifier {
    
    private var player : AVAudioPlayer?
    private let audio : NSURL?
    private var audioChecker = AudioChecker()
    private var isChecking : Bool = false
    
    var debugDelegate : DebugDelegate?
    
    var background: Bool = false
    
    init() {
        guard let path = NSBundle.mainBundle().pathForResource("Alert", ofType: "wav") else {
            print("Failed to load audio file.")
            audio = nil
            return
        }
        audio = NSURL(fileURLWithPath: path)
        player = nil
    }
    
    private func play() {
        player?.stop()
        guard let audio = audio, player = try? AVAudioPlayer(contentsOfURL: audio) else {
            debugDelegate?.debug(self, hasDebugInfo: "Failed to start playing alert", withTimestamp: NSDate())
            return
        }
        self.player = player
        self.player?.numberOfLoops = -1
        self.player?.play()
        debugDelegate?.debug(self, hasDebugInfo: "Started playing alert sound", withTimestamp: NSDate())
    }
    
    private func stop() {
        player?.stop()
        player = nil
        debugDelegate?.debug(self, hasDebugInfo: "Alert sound finished playing.", withTimestamp: NSDate())
    }
    
    func notifyAlertsTriggered(alerts: [Alert]) {
        
        guard !alerts.isEmpty else {
            debugDelegate?.debug(self, hasDebugInfo: "No alerts to trigger.", withTimestamp: NSDate())
            return
        }
        
        guard !(player?.playing ?? false) else {
            debugDelegate?.debug(self, hasDebugInfo: "There is already playing alert", withTimestamp: NSDate())
            return
        }
        
        guard !isChecking else {
            debugDelegate?.debug(self, hasDebugInfo: "Silence mode check is already in progress.", withTimestamp: NSDate())
            return
        }
        
        debugDelegate?.debug(self, hasDebugInfo: "Starting silent mode check...", withTimestamp: NSDate())
        isChecking = true
        audioChecker = AudioChecker()
        audioChecker.debugDelegate = debugDelegate
        audioChecker.silentMode() {
            defer {
                self.debugDelegate?.debug(self, hasDebugInfo: "Silent mode check done.", withTimestamp: NSDate())
                self.isChecking = false
            }
            guard !$0 else {
                self.debugDelegate?.debug(self, hasDebugInfo: "Device is silenced. Alert sound won't be played.", withTimestamp: NSDate())
                return
            }
            self.debugDelegate?.debug(self, hasDebugInfo: "Turning on volume. (Current volume is \(self.audioChecker.volume)).", withTimestamp: NSDate())
            self.audioChecker.volume = 1.0
            self.play()
        }
    }
}

class UIAlertNotifier : AudioAlertNotifier {
    
    private let controller : UIViewController
    private let alertController : UIAlertController
    
    init(presentingViewController : UIViewController) {
        controller = presentingViewController
        alertController = UIAlertController(title: "Alert", message: nil, preferredStyle: .Alert)
        super.init()
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: { _ in
            self.controller.dismissViewControllerAnimated(true, completion: nil)
            AlertManager.sharedManager.resetAll()
            self.stop()
        }))
    }
    
    override func notifyAlertsTriggered(alerts: [Alert]) {
        super.notifyAlertsTriggered(alerts)
        var message = ""
        if let alert = alerts.first?.url {
            message = "\(alert) triggered."
        }
        if alerts.count > 1 {
            message += " And \(alerts.count - 1) more alerts also triggered."
        }
        
        alertController.message = message
        if !background && !alerts.isEmpty && controller.presentedViewController == nil {
            controller.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

private class AudioChecker : MPVolumeView {
    
    private let checker = SilentChecker()
    
    var debugDelegate : DebugDelegate? {
        get {
            return checker.debugDelegate
        }
        set {
            checker.debugDelegate = newValue
        }
    }
    
    private var volumeSlider : UISlider {
        self.showsRouteButton = false
        self.showsVolumeSlider = false
        self.hidden = true
        var slider = UISlider()
        for subview in self.subviews {
            if subview.isKindOfClass(UISlider){
                slider = subview as! UISlider
                slider.continuous = false
                (subview as! UISlider).value = AVAudioSession.sharedInstance().outputVolume
                return slider
            }
        }
        return slider
    }
    
    var volume : Float {
        get {
            return volumeSlider.value
        }
        set {
            volumeSlider.value = newValue
        }
    }
    
    func silentMode(completion : (Bool) -> Void) {
        checker.check() { muted in
            completion(muted)
        }
    }
}
