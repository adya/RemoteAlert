enum AlertState {
    
    /// Alerts hasn't been checked yet.
    case Unknown
    
    /// Alert has invalid properties.
    case Invalid
    
    /// Alert failed to fetch status from given `url`.
    case Broken
    
    /// Alert is valid and ready to be checked.
    case Idle
    
    /// Alert is scheduled. Associated value represents time left before trigger
    case Scheduled(Int)
    
    /// Alert is being checked.
    case Fired
    
    /// Alert has been checked and skipped.
    case Skipped
    
    /// Alert has been checked and triggered.
    case Triggered
}

struct Alert : Hashable, CustomStringConvertible {
    let id : Int
    var url : String
    var interval : Int
    var enabled : Bool
    
    var state = AlertState.Unknown
    
    var hashValue: Int {
        return id
    }
    
    var description: String {
        return "\(id) : \(url) [\(interval)] \(enabled ? "active" : "disabled")"
    }
}

func == (first : Alert, second : Alert) -> Bool {
    return first.id == second.id
}

func != (first : Alert, second : Alert) -> Bool {
    return first.url != second.url ||
        first.interval != second.interval ||
        first.enabled != second.enabled
}

extension Alert : Archivable {
    
    private enum Keys : String {
        case kId = "kAlertId"
        case kInterval = "kAlertInterval"
        case kUrl = "kAlertUrl"
        case kEnabled = "kAlertEnabled"
    }
    
    func archived() -> [String : AnyObject] {
        return [Keys.kId.rawValue : id,
                Keys.kInterval.rawValue : interval,
                Keys.kUrl.rawValue : url,
                Keys.kEnabled.rawValue : enabled
        ]
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[Keys.kId.rawValue] as? Int,
            url = archive[Keys.kUrl.rawValue] as? String,
            interval = archive[Keys.kInterval.rawValue] as? Int,
            enabled = archive[Keys.kEnabled.rawValue] as? Bool else {
                return nil
        }
        self.init(id: id, url: url, interval: interval, enabled: enabled, state: .Unknown)
    }
}