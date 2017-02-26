import UIKit

protocol AlertViewModel : AlertCellDataSource, ValidatableViewModel {
    var alert : Alert? {get}
    var urlProperty : ValidatableProperty<String> {get set}
    var intervalProperty : ValidatableProperty<Int> {get set}
    var enabled: Bool {get set}
}

extension AlertViewModel {
    var validatables: [Validatable] {
        return [urlProperty, intervalProperty]
    }
    
    var url: String? {
        return urlProperty.value
    }
    
    var interval: Int? {
        return intervalProperty.value
    }
}

struct NewAlertViewModel : AlertViewModel {
    var alert : Alert? {
        guard let url = urlProperty.value, let interval = intervalProperty.value, isValid else {
            return nil
        }
        
        return AlertManager.sharedManager.createAlert(url, interval: interval, enabled: enabled)
    }
    
    var urlProperty : ValidatableProperty<String>
    var intervalProperty : ValidatableProperty<Int>
    var enabled: Bool
    
    var active : Bool
    var remaining : Int?
    
    var status: String?
    var statusColor: UIColor?
    
    init(alert : Alert? = nil) {
        urlProperty = ValidatableProperty(value: alert?.url, validators: [NilValidator(), LengthValidator(minLength: 3)])
        intervalProperty = ValidatableProperty(value: alert?.interval, validators: [NilValidator(), ValueValidator(minValue: 1)])
        enabled = alert?.enabled ?? true
        active = false
        if let state = alert?.state{
            if case let .scheduled(rem) = state {
                remaining = rem
            }
            switch state {
            case .scheduled, .fired, .skipped : active = true
            default: active = false
            }
            status = "\(state)"
            if case .triggered = state {
                statusColor = UIColor.mainColor()
            } else {
                statusColor = UIColor.darkText
            }
        }
    }
}

struct EditableAlertViewModel : AlertViewModel {
    var alert: Alert?
    
    var urlProperty : ValidatableProperty<String> {
        didSet {
            if let url = urlProperty.value, urlProperty.isValid {
                alert?.url = url
            }
        }
    }
    var intervalProperty : ValidatableProperty<Int> {
        didSet {
            if let interval = intervalProperty.value, intervalProperty.isValid {
                alert?.interval = interval
            }
        }
    }

    var enabled: Bool {
        didSet {
            alert?.enabled = enabled
        }
    }
    
    var active : Bool
    var remaining : Int?
    
    var status: String?
    var statusColor: UIColor?
    
    init(alert : Alert) {
        self.alert = alert
        urlProperty = ValidatableProperty(value: alert.url, validators: [NilValidator(), LengthValidator(minLength: 3)])
        intervalProperty = ValidatableProperty(value: alert.interval, validators: [NilValidator(), ValueValidator(minValue: 1)])
        enabled = alert.enabled
        if case let .scheduled(rem) = alert.state {
            remaining = rem
        }
        switch alert.state {
        case .scheduled, .fired, .skipped : active = true
        default: active = false
        }
        
        status = "\(alert.state)"
        if case .triggered = alert.state {
            statusColor = UIColor.mainColor()
        } else {
            statusColor = UIColor.darkText
        }
    }

}
