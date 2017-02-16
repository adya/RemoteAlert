import UIKit
import AVFoundation

protocol AlertManagerDelegate {
    /// Occurs whenever `AlertManager` updates alert's state
    func alertManager(manager : AlertManager, didUpdateAlert alert : Alert)
}

class AlertManager {
    
    static let sharedManager = AlertManager()
    
    private(set) var alerts : [Alert] = []
    private let session : NSURLSession
    
    private var lastUpdate : NSDate?
    
    var isInBackground : Bool = false {
        didSet {
            notifier?.background = isInBackground
            if isInBackground {
                prepareForBackground()
            } else {
                prepareForForground()
            }
        }
    }
    
    
    func backgroundUpdate(completion : (Bool) -> Void) {
        guard let min = minimumRemainingTime else {
            print("Failed to update alerts.")
            completion(false)
            return
        }
        
        print("Remote Alert initiated background update.")
        let group = dispatch_group_create()

        scheduledAlerts.forEach {
            dispatch_group_enter(group)
            var new = $0
            if case .Scheduled = new.state {
                new = tickAlert(new, tick: min) {
                    print("Alert updated: \($0)")
                    dispatch_group_leave(group)
                }
            }

        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.prepareForBackground()
            completion(!self.triggeredAlerts.isEmpty)
        }
    }
    
    private func prepareForBackground() {
        guard let min = minimumRemainingTime else {
            print("No Scheduled alerts were found. App will never be awaken to update status.")
            return
        }
        lastUpdate = NSDate()
        saveStorage()
        timer?.invalidate()
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(NSTimeInterval(min))
        print("Remote Alert has scheduled update in \(min) seconds.")
    }
    
    private func prepareForForground() {
        notifier?.notifyAlertsTriggered(triggeredAlerts)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateTick), userInfo: nil, repeats: true)
        print("Remote Alert has become active.")
    }
    
    /// Used to refresh alerts
    private var timer : NSTimer!
    
    var delegate : AlertManagerDelegate?
    var notifier : AlertNotifier?
    
    init() {
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        notifier = AudioAlertNotifier()
        loadStorage()
        if alerts.isEmpty {
            [
                createAlert("http://mop.wow-freakz.com/test/always_true.php", interval: 3, enabled: true),
                createAlert("http://mop.wow-freakz.com/test/always_false.php", interval: 2, enabled: true),
                createAlert("http://mop.wow-freakz.com/test/random.php", interval: 3, enabled: true)
                ].forEach {
                    saveAlert($0)
            }
        }
        scheduleAll()        
    }
    
    var triggeredAlerts : [Alert] {
        return alerts.filter({
            if case .Triggered = $0.state {
                return true
            }
            return false
        })
    }
    
    var scheduledAlerts : [Alert] {
        return alerts.filter({
            if case .Scheduled = $0.state {
                return true
            }
            return false
        })
    }
    
    var minimumRemainingTime : Int?  {
        let test : [Int] =  alerts.flatMap{
            if case .Scheduled(let time) = $0.state {
                return time
            }
            return nil
        }
        
        if let min = test.minElement() {
            return min
        }
        return nil
    }
    
    deinit {
        saveStorage()
        timer.invalidate()
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

// MARK: - Modification
extension AlertManager {
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
}

// MARK: Lifecycle
private extension AlertManager {
    
    /// Updates array of alerts and triggers delegate.
    func updateAlert(alert : Alert) {
        alerts[alert] = alert
        delegate?.alertManager(self, didUpdateAlert: alert)
        print("Alert \(alert.state): \(alert).")
    }
    
    func scheduleAll() {
        alerts.forEach{scheduleAlert($0)}
    }
    
    func scheduleAlert(alert : Alert) {
        if var existing = alerts[alert] where existing.enabled {
            existing.state = .Scheduled(alert.interval)
            updateAlert(existing)
        }
    }
    
    func removeFromSchedule(alert : Alert) {
        guard var existing = alerts[alert] else {
            return
        }
        existing.state = .Idle
        updateAlert(existing)
    }
    
    @objc func updateTick(timer : NSTimer) {
        alerts = alerts.map { tickAlert($0, tick: Int(timer.timeInterval)) }
    }
    
    /// Decrements remaining time for alert and updates it's state
    func tickAlert(alert : Alert, tick : Int, completion : ((Alert) -> ())? = nil) -> Alert {
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
                    default:
                        break
                    }
                    completion?(new)
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

// MARK: Persistence
private extension AlertManager {
    
    enum Keys : String {
        case Alerts = "kAlerts"
        case LastUpdate = "kLastUpdate"
    }
    
    func saveStorage() {
        let archived = alerts.map{$0.archived()}
        print("Saving \(archived)")
        Storage.local[Keys.Alerts.rawValue] = archived
        Storage.local[Keys.Alerts.rawValue] = lastUpdate ?? NSDate()
    }
    
    func loadStorage() {
        let archived = Storage.local[Keys.Alerts.rawValue] as? [[String : AnyObject]] ?? []
        alerts = archived.flatMap{Alert(fromArchive: $0)}
        lastUpdate = Storage.local[Keys.LastUpdate.rawValue] as? NSDate
        print("Alerts loaded (\(alerts.count)): \n\(alerts.reduce(""){$0 + "\($1)\n"}))")
    }
}
