import UIKit

class AlertCell: UITableViewCell, TSTableViewElement {

    @IBOutlet weak private var lUrl: UILabel!
    @IBOutlet weak private var lInterval: UILabel!
    @IBOutlet weak private var sState: UISwitch!
    @IBOutlet weak private var pvRemaining: UIProgressView!
    @IBOutlet weak private var lStatus: UILabel!
    
    private var holder : AlertCellDataSource?
    
    func configure(with dataSource: AlertCellDataSource) {
        holder = DataSourceHolder(dataSource: dataSource)
        lUrl.text = dataSource.url ?? "Unknown"
        lStatus.text = dataSource.status ?? "Unknown"
        lStatus.textColor = dataSource.statusColor ?? UIColor.darkTextColor()
        let interval = dataSource.interval ?? 0
        let remaining = dataSource.remaining ?? 0
        if interval <= 0 {
            lInterval.text = "Never"
        } else {
            lInterval.text = "Every \(interval) second\(interval > 1 ? "s" : "")"
        }
        
        backgroundView = UIView(frame: contentView.frame)
        sState.on = dataSource.enabled
        pvRemaining.hidden = !dataSource.active || interval == 0 || !dataSource.enabled
        if interval != 0 {
            pvRemaining.setProgress(Float(remaining) / Float(interval), animated: false)
        }
        updateState()
    }

    var triggerClosure : AlertCellTriggerClosure?
    
    @IBAction private func triggerAction(sender: UISwitch) {
        triggerClosure?(cell: self, state: sender.on)
        updateState()
    }
    
    private func updateState() {
        if sState.on {
            backgroundView?.backgroundColor = UIColor.whiteColor()
        } else {
            backgroundView?.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        UIView.animateWithDuration(animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    private func select(selected : Bool){
        if selected {
            lUrl?.textColor = UIColor.whiteColor()
            lInterval?.textColor = UIColor.whiteColor()
            lStatus?.textColor = UIColor.whiteColor()
            self.contentView.backgroundColor = UIColor.mainColor()
        }
        else {
            self.lUrl?.textColor = UIColor.darkTextColor()
            self.lInterval?.textColor = UIColor.darkTextColor()
            lStatus?.textColor =  holder?.statusColor ?? UIColor.darkTextColor()
            self.contentView.backgroundColor = nil
        }
    }

}

typealias AlertCellTriggerClosure = (cell : AlertCell, state : Bool) -> Void

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
