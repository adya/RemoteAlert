import UIKit
import AVFoundation
import AudioToolbox

protocol AlertNotifier {
    func notifyAlertsTriggered(alert : [Alert])
    var background : Bool {get set}
}

class AudioAlertNotifier : AlertNotifier {
    
    private var playing : Bool = false
    private let sound : SystemSoundID
    var background: Bool = false
    
    init() {
        guard let url = NSBundle.mainBundle().URLForResource("Alert", withExtension: "wav") else {
            print("Failed to load audio file.")
            self.sound = 0
            return
        }
        
        
        var sound : SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &sound)
        self.sound = sound
        
        let data = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        AudioServicesAddSystemSoundCompletion(sound, nil, nil, { sound, data in
            let me = unsafeBitCast(data, AudioAlertNotifier.self)
            if me.playing {
                AudioServicesPlaySystemSound(sound)
            }
        }, data)
    }
    
    private func play() {
        playing = true
        AudioServicesPlaySystemSound(sound)
    }
    
    private func stop() {
        playing = false
    }
    
    func notifyAlertsTriggered(alerts: [Alert]) {
        if !alerts.isEmpty && !playing {
            play()
        }
    }
    
    deinit {
        AudioServicesDisposeSystemSoundID(sound)
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