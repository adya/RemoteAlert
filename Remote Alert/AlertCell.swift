import UIKit

class AlertCell: UITableViewCell, TSTableViewElement {

    @IBOutlet weak fileprivate var lUrl: UILabel!
    @IBOutlet weak fileprivate var lInterval: UILabel!
    @IBOutlet weak fileprivate var sState: UISwitch!
    @IBOutlet weak fileprivate var pvRemaining: UIProgressView!
    @IBOutlet weak fileprivate var lStatus: UILabel!
    
    fileprivate var holder : AlertCellDataSource?
    
    func configure(with dataSource: AlertCellDataSource) {
        holder = DataSourceHolder(dataSource: dataSource)
        lUrl.text = dataSource.url ?? "Unknown"
        lStatus.text = dataSource.status ?? "Unknown"
        lStatus.textColor = dataSource.statusColor ?? UIColor.darkText
        let interval = dataSource.interval ?? 0
        let remaining = dataSource.remaining ?? 0
        if interval <= 0 {
            lInterval.text = "Never"
        } else {
            lInterval.text = "Every \(interval) second\(interval > 1 ? "s" : "")"
        }
        
        backgroundView = UIView(frame: contentView.frame)
        sState.isOn = dataSource.enabled
        pvRemaining.isHidden = !dataSource.active || interval == 0 || !dataSource.enabled
        if interval != 0 {
            pvRemaining.setProgress(Float(remaining) / Float(interval), animated: false)
        }
        updateState()
    }

    var triggerClosure : AlertCellTriggerClosure?
    
    @IBAction fileprivate func triggerAction(_ sender: UISwitch) {
        triggerClosure?(self, sender.isOn)
        updateState()
    }
    
    fileprivate func updateState() {
        if sState.isOn {
            backgroundView?.backgroundColor = UIColor.white
        } else {
            backgroundView?.backgroundColor = UIColor.lightGray
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            lUrl?.textColor = UIColor.white
            lInterval?.textColor = UIColor.white
            lStatus?.textColor = UIColor.white
            self.contentView.backgroundColor = UIColor.mainColor()
        }
        else {
            self.lUrl?.textColor = UIColor.darkText
            self.lInterval?.textColor = UIColor.darkText
            lStatus?.textColor =  holder?.statusColor ?? UIColor.darkText
            self.contentView.backgroundColor = nil
        }
    }

}

typealias AlertCellTriggerClosure = (_ cell : AlertCell, _ state : Bool) -> Void

private struct DataSourceHolder : AlertCellDataSource {
    var interval: Int?
    var remaining: Int?
    var url: String?
    var enabled: Bool
    var active: Bool
    var status: String?
    var statusColor: UIColor?
    
    init(dataSource : AlertCellDataSource) {
        interval = dataSource.interval
        remaining = dataSource.remaining
        url = dataSource.url
        enabled = dataSource.enabled
        active = dataSource.active
        status = dataSource.status
        statusColor = dataSource.statusColor
    }
}

protocol AlertCellDataSource {
    var interval : Int? {get}
    var remaining : Int? {get}
    
    var url : String? {get}
    var enabled : Bool {get}
    var active : Bool {get}
    
    var status : String? {get}
    var statusColor : UIColor? {get}
}
