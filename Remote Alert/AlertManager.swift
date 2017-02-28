import Foundation
import AVFoundation
import UIKit

protocol AlertManagerDelegate {
    /// Occurs whenever `AlertManager` updates alert's state
    func alertManager(_ manager : AlertManager, didUpdateAlert alert : Alert)
}

class AlertManager {
    
    static let sharedManager = AlertManager()
    
    fileprivate(set) var alerts : [Alert] = []
    
    fileprivate let session : URLSession
    
    fileprivate let backgroundPlayer : AVPlayer!
    
    /// Used to refresh alerts
    fileprivate var timer : Timer!
    
    var debugDelegate : DebugDelegate? {
        didSet {
            notifier?.debugDelegate = debugDelegate
        }
    }
    
    var delegate : AlertManagerDelegate?
    var notifier : AlertNotifier? {
        didSet {
            notifier?.debugDelegate = debugDelegate
        }
    }
    
    init() {
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        session = URLSession(configuration: URLSessionConfiguration.default)
        let url = Bundle.main.url(forResource: "silence", withExtension: "mp3")
        backgroundPlayer = AVPlayer(url: url!)
        backgroundPlayer.actionAtItemEnd = .none // keep it alive
        backgroundPlayer.play()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTick), userInfo: nil, repeats: true)
        
        loadStorage()
//        if alerts.isEmpty {
//            [
//                createAlert("http://mop.wow-freakz.com/test/always_true.php", interval: 3, enabled: true),
//                createAlert("http://mop.wow-freakz.com/test/always_false.php", interval: 2, enabled: true),
//                createAlert("http://mop.wow-freakz.com/test/random.php", interval: 3, enabled: true)
//                ].forEach {
//                    saveAlert($0)
//            }
//        }
        scheduleAll()
        
    }
    
    var triggeredAlerts : [Alert] {
        return self.alerts.filter({
            if case .triggered = $0.state {
                return true
            }
            return false
        })
    }
    
    func removeAlert(_ alert : Alert) {
        alerts[alert] = nil
        removeFromSchedule(alert)
        saveStorage()
    }
    
    func saveAlert(_ alert : Alert) {
        let existing = alerts[alert]
        if existing == nil{
            alerts.append(alert)
            scheduleAlert(alert)
            saveStorage()
            print("Alert added \(alert).")
            
        } else if existing! != alert  {
            alerts[alert] = alert
            if alert.enabled {
                scheduleAlert(alert)
            } else {
                removeFromSchedule(alert)
            }
            saveStorage()
            print("Alert saved: \(alert).")
        }
    }
    
    func resetAlert(_ alert : Alert) {
        guard case .triggered = alert.state else {
            return
        }
        scheduleAlert(alert)
    }
    
    func resetAll() {
        triggeredAlerts.forEach {
            resetAlert($0)
        }
    }
    
    fileprivate func scheduleAll() {
        alerts.forEach{scheduleAlert($0)}
    }
    
    fileprivate func scheduleAlert(_ alert : Alert) {
        if var existing = alerts[alert], existing.enabled {
            existing.state = .scheduled(alert.interval)
            updateAlert(existing)
        }
    }
    
    /// Updates array of alerts and triggers delegate.
    fileprivate func updateAlert(_ alert : Alert) {
        alerts[alert] = alert
        delegate?.alertManager(self, didUpdateAlert: alert)
        print("Alert \(alert.state): \(alert).")
    }
    
    fileprivate func removeFromSchedule(_ alert : Alert) {
        guard var existing = alerts[alert] else {
            return
        }
        existing.state = .idle
        updateAlert(existing)
    }
    
    fileprivate enum Keys : String {
        case Alerts = "kAlerts"
    }
    
    deinit {
        timer.invalidate()
    }
}

// MARK: Updater
private extension AlertManager {
    @objc func updateTick(_ timer : Timer) {
        backgroundPlayer.play() // probably ensure that background playback is still alive.
        alerts = alerts.map { tickAlert($0) }
    }
    
    /// Decrements remaining time for alert and updates it's state
    func tickAlert(_ alert : Alert) -> Alert {
        let tick = Int(timer.timeInterval)
        if case let .scheduled(current) = alert.state {
            var new = alert
            let remaining = current - tick
            if remaining <= 0 {
                new.state = .fired
                checkAlert(new) {
                    self.updateAlert($0)
                    switch $0.state {
                    case .skipped: self.scheduleAlert(new)
                    case .triggered:
                        self.notifier?.notifyAlertsTriggered(self.triggeredAlerts)
                        if self.notifier == nil {
                            print("AlertNotifier wasn't set, triggered alerts won't be notified.")
                        }
                    default: break
                    }
                }
            } else {
                new.state = .scheduled(remaining)
            }
            delegate?.alertManager(self, didUpdateAlert: new)
            return new
        }
        return alert
    }
    
    /// Checks alert url.
    func checkAlert(_ alert : Alert, completion : ((Alert) -> ())? = nil) {
        if let url = URL(string: alert.url) {
            print("Checking alert: \(alert)...")
            session.dataTask(with: url, completionHandler: {data,_,_ in
                var new = alert
                defer {
                    DispatchQueue.main.async {
                        completion?(new)
                    }
                }
                guard let data = data, let string = String(data: data, encoding: String.Encoding.utf8) else {
                    print("Request failed: \(alert).")
                    new.state = .broken
                    new.enabled = false
                    return
                }
                guard let value = Int(string), (0...1).contains(value) else {
                    print("Unexpected response: \(alert).")
                    new.state = .broken
                    new.enabled = false
                    return
                }
                
                if value == 0 {
                    new.state = .skipped
                } else {
                    new.state = .triggered
                }
                }) .resume()
        } else {
            var new = alert
            new.state = .invalid
            print("Invalid url: \(alert).")
        }
    }
}

// MARK: Generation
extension AlertManager {
    func createAlert(_ url : String, interval : Int, enabled : Bool) -> Alert {
        let ids = alerts.map{$0.id}
        var unique : Int
        repeat {
            unique = Int(arc4random_uniform(100000))
        } while ids.contains(unique)
        return Alert(id: unique, url: url, interval: interval, enabled: enabled, state: .unknown)
    }
}

// MARK: Persistence
private extension AlertManager {
    func saveStorage() {
        let archived = alerts.map{$0.archived()}
        Storage.local[Keys.Alerts.rawValue] = archived as AnyObject?
    }
    
    func loadStorage() {
        let archived = Storage.local.loadObjectForKey(Keys.Alerts.rawValue) as? [[String : AnyObject]] ?? []
        alerts = archived.flatMap{Alert(fromArchive: $0)}
        print("Alerts loaded (\(alerts.count)): \n\(alerts.reduce(""){$0 + "\($1)\n"}))")
    }
}
