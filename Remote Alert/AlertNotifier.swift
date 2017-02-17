import UIKit
import AVFoundation
import MediaPlayer

protocol AlertNotifier {
    func notifyAlertsTriggered(alert : [Alert])
    var background : Bool {get set}
}

class AudioAlertNotifier : AlertNotifier {
    
    private var player : AVAudioPlayer?
    private let audio : NSURL?
    private let audioChecker = AudioChecker()
    
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
            return
        }
        self.player = player
        self.player?.numberOfLoops = -1
        self.player?.play()
    }
    
    private func stop() {
        player?.stop()
        player = nil
    }
    
    func notifyAlertsTriggered(alerts: [Alert]) {
        if !alerts.isEmpty && !(player?.playing ?? false) {
            audioChecker.silentMode() {
                guard !$0 else {
                    return
                }
                self.audioChecker.volume = 1.0
                self.play()
            }
            
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
        MuteChecker() { _, muted in
            completion(muted)
            }.check()
    }
}
