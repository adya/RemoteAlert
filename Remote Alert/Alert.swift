enum AlertState : Archivable {
    
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
    
    func archived() -> [String : AnyObject] {
        var archive : [String : AnyObject] = [Keys.kIdentifier.rawValue : identifier]
        if case let .Scheduled(time) = self {
            archive[Keys.kRemaining.rawValue] = time
        }
        return archive
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let identifier = archive[Keys.kIdentifier.rawValue] as? String else {
            return nil
        }
        
        let states : [AlertState] = [.Unknown, .Invalid, .Broken, .Idle, .Fired, .Skipped, .Triggered]
        guard let index = states.map({$0.identifier}).indexOf(identifier) else {
            return nil
        }
        
        if let remaining = archive[Keys.kRemaining.rawValue] as? Int {
            self = .Scheduled(remaining)
        } else {
            self = states[index]
        }
        
    }
    
    private var identifier : String {
        switch self {
        case .Scheduled: return "Scheduled"
        default: return String(self)
        }
    }
    
    private enum Keys : String {
        case kIdentifier = "kState"
        case kRemaining = "kStateRemaining"
    }
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
        case kState = "kAlertState"
    }
    
    func archived() -> [String : AnyObject] {
        return [Keys.kId.rawValue : id,
                Keys.kInterval.rawValue : interval,
                Keys.kUrl.rawValue : url,
                Keys.kState.rawValue : state.archived(),
                Keys.kEnabled.rawValue : enabled
        ]
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[Keys.kId.rawValue] as? Int,
            url = archive[Keys.kUrl.rawValue] as? String,
            interval = archive[Keys.kInterval.rawValue] as? Int,
        state = (archive[Keys.kState.rawValue] as? [String : AnyObject]).flatMap({AlertState(fromArchive: $0)}),
            enabled = archive[Keys.kEnabled.rawValue] as? Bool else {
                return nil
        }
        self.init(id: id, url: url, interval: interval, enabled: enabled, state: state)
    }
}