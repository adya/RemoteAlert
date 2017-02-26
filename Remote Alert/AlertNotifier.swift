import UIKit
import AVFoundation
import MediaPlayer

protocol AlertNotifier {
    func notifyAlertsTriggered(_ alert : [Alert])
    var background : Bool {get set}
    var debugDelegate : DebugDelegate? {get set}
}

class AudioAlertNotifier : AlertNotifier {
    
    fileprivate var player : AVAudioPlayer?
    fileprivate let audio : URL?
    fileprivate var audioChecker = AudioChecker()
    fileprivate var isChecking : Bool = false
    
    var debugDelegate : DebugDelegate?
    
    var background: Bool = false
    
    init() {
        guard let path = Bundle.main.path(forResource: "Alert", ofType: "wav") else {
            print("Failed to load audio file.")
            audio = nil
            return
        }
        audio = URL(fileURLWithPath: path)
        player = nil
    }
    
    fileprivate func play() {
        player?.stop()
        guard let audio = audio, let player = try? AVAudioPlayer(contentsOf: audio) else {
            debugDelegate?.debug(self, hasDebugInfo: "Failed to start playing alert", withTimestamp: Date())
            return
        }
        self.player = player
        self.player?.numberOfLoops = -1
        self.player?.play()
        debugDelegate?.debug(self, hasDebugInfo: "Started playing alert sound", withTimestamp: Date())
    }
    
    fileprivate func stop() {
        player?.stop()
        player = nil
        debugDelegate?.debug(self, hasDebugInfo: "Alert sound finished playing.", withTimestamp: Date())
    }
    
    func notifyAlertsTriggered(_ alerts: [Alert]) {
        
        guard !alerts.isEmpty else {
            debugDelegate?.debug(self, hasDebugInfo: "No alerts to trigger.", withTimestamp: Date())
            return
        }
        
        guard !(player?.isPlaying ?? false) else {
            debugDelegate?.debug(self, hasDebugInfo: "There is already playing alert", withTimestamp: Date())
            return
        }
        
        guard !isChecking else {
            debugDelegate?.debug(self, hasDebugInfo: "Silence mode check is already in progress.", withTimestamp: Date())
            return
        }
        
        debugDelegate?.debug(self, hasDebugInfo: "Starting silent mode check...", withTimestamp: Date())
        isChecking = true
        audioChecker = AudioChecker()
        audioChecker.debugDelegate = debugDelegate
        audioChecker.silentMode() {
            defer {
                self.debugDelegate?.debug(self, hasDebugInfo: "Silent mode check done.", withTimestamp: Date())
                self.isChecking = false
            }
            guard !$0 else {
                self.debugDelegate?.debug(self, hasDebugInfo: "Device is silenced. Alert sound won't be played.", withTimestamp: Date())
                return
            }
            self.debugDelegate?.debug(self, hasDebugInfo: "Turning on volume. (Current volume is \(self.audioChecker.volume)).", withTimestamp: Date())
            self.audioChecker.volume = 1.0
            self.play()
        }
    }
}

class UIAlertNotifier : AudioAlertNotifier {
    
    fileprivate let controller : UIViewController
    fileprivate let alertController : UIAlertController
    
    init(presentingViewController : UIViewController) {
        controller = presentingViewController
        alertController = UIAlertController(title: "Alert", message: nil, preferredStyle: .alert)
        super.init()
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in
            self.controller.dismiss(animated: true, completion: nil)
            AlertManager.sharedManager.resetAll()
            self.stop()
        }))
    }
    
    override func notifyAlertsTriggered(_ alerts: [Alert]) {
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
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}

private class AudioChecker : MPVolumeView {
    
    fileprivate let checker = SilentChecker()
    
    var debugDelegate : DebugDelegate? {
        get {
            return checker.debugDelegate
        }
        set {
            checker.debugDelegate = newValue
        }
    }
    
    fileprivate var volumeSlider : UISlider {
        self.showsRouteButton = false
        self.showsVolumeSlider = false
        self.isHidden = true
        var slider = UISlider()
        for subview in self.subviews {
            if subview.isKind(of: UISlider.self){
                slider = subview as! UISlider
                slider.isContinuous = false
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
    
    func silentMode(_ completion : @escaping (Bool) -> Void) {
        checker.check() { muted in
            completion(muted)
        }
    }
}
