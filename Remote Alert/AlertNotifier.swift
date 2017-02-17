import UIKit
import AVFoundation

protocol AlertNotifier {
    func notifyAlertsTriggered(alert : [Alert])
    var background : Bool {get set}
}

class AudioAlertNotifier : AlertNotifier {
    
    private var player : AVAudioPlayer?
    private let audio : NSURL?
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
    
    private func setSystemVolumeLevel(newVolumeLevel : Float) {
        let avSystemControllerClass = NSClassFromString("AVSystemController") as? NSObjectProtocol
        let avSystemControllerInstance = avSystemControllerClass?.performSelector(Selector("sharedAVSystemController"))?.takeUnretainedValue()
        let category = AVAudioSessionCategoryPlayback
        avSystemControllerInstance?.performSelector(Selector("setVolumeTo:forCategory:"), withObject: newVolumeLevel, withObject: category)
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
            setSystemVolumeLevel(1.0)
            play()
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