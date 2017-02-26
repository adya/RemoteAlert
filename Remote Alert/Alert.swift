enum AlertState {
    
    /// Alerts hasn't been checked yet.
    case unknown
    
    /// Alert has invalid properties.
    case invalid
    
    /// Alert failed to fetch status from given `url`.
    case broken
    
    /// Alert is valid and ready to be checked.
    case idle
    
    /// Alert is scheduled. Associated value represents time left before trigger
    case scheduled(Int)
    
    /// Alert is being checked.
    case fired
    
    /// Alert has been checked and skipped.
    case skipped
    
    /// Alert has been checked and triggered.
    case triggered
}

struct Alert : Hashable, CustomStringConvertible {
    let id : Int
    var url : String
    var interval : Int
    var enabled : Bool
    
    var state = AlertState.unknown
    
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
    
    fileprivate enum Keys : String {
        case kId = "kAlertId"
        case kInterval = "kAlertInterval"
        case kUrl = "kAlertUrl"
        case kEnabled = "kAlertEnabled"
    }
    
    func archived() -> [String : AnyObject] {
        return [Keys.kId.rawValue : id as AnyObject,
                Keys.kInterval.rawValue : interval as AnyObject,
                Keys.kUrl.rawValue : url as AnyObject,
                Keys.kEnabled.rawValue : enabled as AnyObject
        ]
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[Keys.kId.rawValue] as? Int,
            let url = archive[Keys.kUrl.rawValue] as? String,
            let interval = archive[Keys.kInterval.rawValue] as? Int,
            let enabled = archive[Keys.kEnabled.rawValue] as? Bool else {
                return nil
        }
        self.init(id: id, url: url, interval: interval, enabled: enabled, state: .unknown)
    }
}
