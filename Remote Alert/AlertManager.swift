import Foundation
import AVFoundation

protocol AlertManagerDelegate {
    /// Occurs whenever `AlertManager` updates alert's state
    func alertManager(manager : AlertManager, didUpdateAlert alert : Alert)
}

class AlertManager {
    
    static let sharedManager = AlertManager()
    
    private(set) var alerts : [Alert] = []
    
    private let session : NSURLSession
    
    /// Used to refresh alerts
    private var timer : NSTimer!
    
    var delegate : AlertManagerDelegate?
    var notifier : AlertNotifier?
    
    init() {
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateTick), userInfo: nil, repeats: true)
        
        loadStorage()
//        [
//            createAlert("http://mop.wow-freakz.com/test/always_true.php", interval: 3, enabled: true),
//            createAlert("http://mop.wow-freakz.com/test/always_false.php", interval: 2, enabled: true),
//            createAlert("http://mop.wow-freakz.com/test/random.php", interval: 3, enabled: true)
//        ].forEach {
//            saveAlert($0)
//        }
        scheduleAll()
       
    }
    
    var triggeredAlerts : [Alert] {
        return self.alerts.filter({
            if case .Triggered = $0.state {
                return true
            }
            return false
        })
    }
    
    func removeAlert(alert : Alert) {
        alerts[alert] = nil
        removeFromSchedule(alert)
        saveStorage()
    }
    
    func saveAlert(alert : Alert) {
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
    
    func resetAlert(alert : Alert) {
        guard case .Triggered = alert.state else {
            return
        }
        scheduleAlert(alert)
    }
    
    func resetAll() {
        triggeredAlerts.forEach {
            resetAlert($0)
        }
    }
    
    private func scheduleAll() {
        alerts.forEach{scheduleAlert($0)}
    }
    
    private func scheduleAlert(alert : Alert) {
        if var existing = alerts[alert] where existing.enabled {
            existing.state = .Scheduled(alert.interval)
            updateAlert(existing)
        }
    }
    
    /// Updates array of alerts and triggers delegate.
    private func updateAlert(alert : Alert) {
        alerts[alert] = alert
        delegate?.alertManager(self, didUpdateAlert: alert)
        print("Alert \(alert.state): \(alert).")
    }
    
    /// Performs any actions to notify user (play sound, bring alert).
    private func triggerAlert(alert : Alert) {
        AudioServicesPlayAlertSound(SystemSoundID(1000)) // CalendarAlert
    }
    
    private func removeFromSchedule(alert : Alert) {
        guard var existing = alerts[alert] else {
            return
        }
        existing.state = .Idle
        updateAlert(existing)
    }
    
    private enum Keys : String {
        case Alerts = "kAlerts"
    }
    
    deinit {
        timer.invalidate()
    }
}

// MARK: Updater
private extension AlertManager {
    @objc func updateTick(timer : NSTimer) {
        alerts = alerts.map { tickAlert($0) }
    }
    
    /// Decrements remaining time for alert and updates it's state
    func tickAlert(alert : Alert) -> Alert {
        let tick = Int(timer.timeInterval)
        if case let .Scheduled(current) = alert.state {
            var new = alert
            let remaining = current - tick
            if remaining <= 0 {
                new.state = .Fired
                checkAlert(new) {
                    self.updateAlert($0)
                    switch $0.state {
                    case .Skipped: self.scheduleAlert(new)
                    case .Triggered:
                        self.notifier?.notifyAlertsTriggered(self.triggeredAlerts)
                        if self.notifier == nil {
                            print("AlertNotifier wasn't set, triggered alerts won't be notified.")
                        }
                    default: break
                    }
                }
            } else {
                new.state = .Scheduled(remaining)
            }
            delegate?.alertManager(self, didUpdateAlert: new)
            return new
        }
        return alert
    }
    
    /// Checks alert url.
    func checkAlert(alert : Alert, completion : ((Alert) -> ())? = nil) {
        if let url = NSURL(string: alert.url) {
            print("Checking alert: \(alert)...")
            session.dataTaskWithURL(url) {data,_,_ in
                var new = alert
                defer {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion?(new)
                    }
                }
                guard let data = data, string = String(data: data, encoding: NSUTF8StringEncoding) else {
                    print("Request failed: \(alert).")
                    new.state = .Broken
                    new.enabled = false
                    return
                }
                guard let value = Int(string) where (0...1).contains(value) else {
                    print("Unexpected response: \(alert).")
                    new.state = .Broken
                    new.enabled = false
                    return
                }
                
                if value == 0 {
                    new.state = .Skipped
                } else {
                    new.state = .Triggered
                }
                }.resume()
        } else {
            var new = alert
            new.state = .Invalid
            print("Invalid url: \(alert).")
        }
    }
}

// MARK: Generation
extension AlertManager {
    func createAlert(url : String, interval : Int, enabled : Bool) -> Alert {
        let ids = alerts.map{$0.id}
        var unique : Int
        repeat {
            unique = Int(arc4random())
        } while ids.contains(unique)
        return Alert(id: unique, url: url, interval: interval, enabled: enabled, state: .Unknown)
    }
}

// MARK: Persistence
private extension AlertManager {
    func saveStorage() {
        let archived = alerts.map{$0.archived()}
        Storage.local[Keys.Alerts.rawValue] = archived
    }
    
    func loadStorage() {
        let archived = Storage.local.loadObjectForKey(Keys.Alerts.rawValue) as? [[String : AnyObject]] ?? []
        alerts = archived.flatMap{Alert(fromArchive: $0)}
        print("Alerts loaded (\(alerts.count)): \n\(alerts.reduce(""){$0 + "\($1)\n"}))")
    }
}
