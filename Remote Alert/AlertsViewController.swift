import UIKit

class AlertsViewController: UIViewController, UIPopoverPresentationControllerDelegate, AlertEditorDelegate {

    private enum Segues : String {
        case addAlert = "segPopup"
    }
    
    @IBOutlet weak private var tvAlerts: UITableView!
    
    private let manager = AlertManager.sharedManager
    private var editor : AddAlertViewController!
    private var viewModel : [AlertViewModel]!
    private var selectedAlert : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = manager.alerts.map{EditableAlertViewModel(alert: $0)}
        editor = AddAlertViewController(manager: manager)
        editor.modalPresentationStyle = .Popover
        editor.modalInPopover = true
        editor.preferredContentSize = CGSize(width: 300, height: 180)
        editor.delegate = self
        manager.delegate = self
        tvAlerts.estimatedRowHeight = 60.0
        tvAlerts.rowHeight = UITableViewAutomaticDimension
        manager.notifier = UIAlertNotifier(presentingViewController: self)
    }
    
    @IBAction func addAction(sender: UIButton) {
        showPopover(sender)
    }
    
    func showPopover(base: UIView)
    {
        if let popover = editor.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = base
            popover.sourceRect = base.bounds
            popover.permittedArrowDirections = [.Up, .Down]
            self.presentViewController(editor, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func alertEditor(editor: AlertEditor, didEdit alert: AlertViewModel) {
        if let index = selectedAlert where alert.isValid {
            viewModel[index.row] = alert
            tvAlerts.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
            selectedAlert = nil
        }
        dismissViewControllerAnimated(true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
    
    func alertEditor(editor: AlertEditor, didAdd alertViewModel: AlertViewModel) {
        
        if let alert = alertViewModel.alert where alertViewModel.isValid {
            viewModel?.append(EditableAlertViewModel(alert: alert))
            if !hasAlerts {
                tvAlerts.reloadData()
            } else {
                tvAlerts.insertRowsAtIndexPaths([NSIndexPath(forRow: viewModel.count - 1, inSection: 0)], withRowAnimation: .Automatic)
            }
            manager.saveAlert(alert)
        }
        dismissViewControllerAnimated(true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
    
    func alertEditorDidCancel(editor: AlertEditor) {
        dismissViewControllerAnimated(true) { _ in
            editor.reset()
            self.manager.notifier?.notifyAlertsTriggered(self.manager.triggeredAlerts)
        }
    }
}

extension AlertsViewController : AlertManagerDelegate {
    func alertManager(manager: AlertManager, didUpdateAlert alert: Alert) {
        if let index = viewModel.indexOf({$0.alert! == alert}) {
            viewModel[index] = EditableAlertViewModel(alert: alert)
            tvAlerts.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
        }
    }
}


extension AlertsViewController : UITableViewDelegate, UITableViewDataSource {
    private var hasAlerts : Bool {
        return viewModel?.count ?? 0 > 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasAlerts ? viewModel!.count : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard hasAlerts else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell")
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return hasAlerts
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if hasAlerts && editingStyle == .Delete {
            if let alert = viewModel[indexPath.row].alert {
                manager.removeAlert(alert)
                viewModel.removeAtIndex(indexPath.row)
                tableView.reloadData()
//                if !hasAlerts {
//                    tableView.reloadData()
//                } else {
//                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if hasAlerts, let alert = viewModel[indexPath.row].alert where !alert.enabled {
            editor.setAlert(alert)
            selectedAlert = indexPath
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                showPopover(cell)
            }
        } else if hasAlerts {
            print("Can't edited active alert.")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
