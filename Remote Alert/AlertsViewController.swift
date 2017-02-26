import UIKit

class AlertsViewController: UIViewController, UIPopoverPresentationControllerDelegate, AlertEditorDelegate {

    fileprivate enum Segues : String {
        case addAlert = "segPopup"
    }
    
    @IBOutlet weak fileprivate var tvAlerts: UITableView!
    @IBOutlet weak fileprivate var tvDebug: UITextView!
    
    fileprivate let manager = AlertManager.sharedManager
    fileprivate var editor : AddAlertViewController!
    fileprivate var viewModel : [AlertViewModel]!
    fileprivate var selectedAlert : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = manager.alerts.map{EditableAlertViewModel(alert: $0)}
        editor = AddAlertViewController(manager: manager)
        editor.modalPresentationStyle = .popover
        editor.isModalInPopover = true
        editor.preferredContentSize = CGSize(width: 300, height: 180)
        editor.delegate = self
        manager.delegate = self
        tvAlerts.estimatedRowHeight = 60.0
        tvAlerts.rowHeight = UITableViewAutomaticDimension
        manager.notifier = UIAlertNotifier(presentingViewController: self)
    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        manager.debugDelegate = self
//    }
    
    @IBAction func addAction(_ sender: UIButton) {
        showPopover(sender)
    }
    
    @IBAction func clipboardAction(_ sender: UIButton) {
        if let debug = tvDebug.text {
            UIPasteboard.general.string = debug
        }
    }
    
    func showPopover(_ base: UIView)
    {
        if let popover = editor.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = base
            popover.sourceRect = base.bounds
            popover.permittedArrowDirections = [.up, .down]
            self.present(editor, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func alertEditor(_ editor: AlertEditor, didEdit alert: AlertViewModel) {
        if let index = selectedAlert, alert.isValid {
            viewModel[index.row] = alert
            tvAlerts.reloadRows(at: [index], with: .automatic)
            selectedAlert = nil
        }
        dismiss(animated: true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
    
    func alertEditor(_ editor: AlertEditor, didAdd alertViewModel: AlertViewModel) {
        
        if let alert = alertViewModel.alert, alertViewModel.isValid {
            let isFirst = !hasAlerts
            viewModel?.append(EditableAlertViewModel(alert: alert))
            if isFirst {
                tvAlerts.reloadData()
            } else {
                tvAlerts.insertRows(at: [IndexPath(row: viewModel.count - 1, section: 0)], with: .automatic)
            }
            manager.saveAlert(alert)
        }
        dismiss(animated: true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
    
    func alertEditorDidCancel(_ editor: AlertEditor) {
        dismiss(animated: true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
}

extension AlertsViewController : AlertManagerDelegate {
    func alertManager(_ manager: AlertManager, didUpdateAlert alert: Alert) {
        if let index = viewModel.index(where: {$0.alert! == alert}) {
            viewModel[index] = EditableAlertViewModel(alert: alert)
            tvAlerts.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}

extension AlertsViewController : DebugDelegate {
    func debug(_ alertManager: AlertManager, hasDebugInfo info: String, withTimestamp timestamp: Date) {
        printDebug(alertManager, message: info, timestamp: timestamp)
    }
    
    func debug(_ alertNotifier: AlertNotifier, hasDebugInfo info: String, withTimestamp timestamp: Date) {
        printDebug(alertNotifier, message: info, timestamp: timestamp)
    }
    
    func debug(_ silentChecker: SilentChecker, hasDebugInfo info: String, withTimestamp timestamp: Date) {
        printDebug(silentChecker, message: info, timestamp: timestamp)
    }
    
    func printDebug(_ sender : Any, message : String, timestamp : Date) {
        let debug = "\(timestamp.toString(withFormat: "HH:mm:ss.SSS")) - \(type(of: sender)): \(message)"
        print(debug)
        tvDebug.text = tvDebug.text + "\n\(debug)"
    }
}


extension AlertsViewController : UITableViewDelegate, UITableViewDataSource {
    fileprivate var hasAlerts : Bool {
        return viewModel?.count ?? 0 > 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasAlerts ? viewModel!.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard hasAlerts else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell")
            return cell!
        }
        let cell = tableView.dequeueReusableCellOfType(AlertCell.self)
        cell.configure(with: viewModel[indexPath.row])
        cell.triggerClosure = {
            self.viewModel?[indexPath.row].enabled = $1
            if let alert = self.viewModel?[indexPath.row].alert {
                self.manager.saveAlert(alert)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return hasAlerts
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if hasAlerts && editingStyle == .delete {
            if let alert = viewModel[indexPath.row].alert {
                manager.removeAlert(alert)
                viewModel.remove(at: indexPath.row)
                tableView.reloadData()
//                if !hasAlerts {
//                    tableView.reloadData()
//                } else {
//                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasAlerts, let alert = viewModel[indexPath.row].alert, !alert.enabled {
            editor.setAlert(alert)
            selectedAlert = indexPath
            if let cell = tableView.cellForRow(at: indexPath) {
                showPopover(cell)
            }
        } else if hasAlerts {
            print("Can't edited active alert.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
