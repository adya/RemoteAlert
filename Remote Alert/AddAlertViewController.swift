import UIKit

protocol AlertEditor {
    var delegate : AlertEditorDelegate? {get set}
    func setAlert(alert : Alert)
    func reset()
}

protocol AlertEditorDelegate {
    func alertEditor(editor : AlertEditor, didEdit alert : AlertViewModel)
    func alertEditor(editor : AlertEditor, didAdd alert : AlertViewModel)
    func alertEditorDidCancel(editor : AlertEditor)
}

class AddAlertViewController: StandaloneViewController, AlertEditor, UITextFieldDelegate {

    @IBOutlet weak private var tfUrl: UITextField!
    @IBOutlet weak private var tfInterval: UITextField!
    @IBOutlet weak private var sInterval: UIStepper!
    @IBOutlet weak private var bSave: UIButton!
    
    private let manager : AlertManager
    private var mode : Mode = .Add
    
    var delegate : AlertEditorDelegate?
    var viewModel : AlertViewModel! {
        didSet {
            if isViewLoaded() {
                configure()
            }
        }
    }
    
    init(manager : AlertManager) {
        self.manager = manager
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            reset()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel != nil {
            configure()
        }
        resetErrors()
        bSave.setTitle(mode == .Add ? "Add" : "Save", forState: .Normal)
    }
    
    func setAlert(alert: Alert) {
        viewModel = EditableAlertViewModel(alert: alert)
        mode = .Edit
        if isViewLoaded() {
            resetErrors()
        }
    }
    
    func reset() {
        viewModel = NewAlertViewModel()
        if isViewLoaded() {
            resetErrors()
        }
        mode = .Add
    }
    
    func configure() {
        tfUrl.text = viewModel.urlProperty.value
        tfInterval.text = viewModel.intervalProperty.value.flatMap{"\($0)"}
        let value = viewModel.intervalProperty.value.flatMap{Double($0)} ?? 0
        sInterval.value = value
        sInterval.maximumValue = value + 1
    }
    @IBAction func intervalChangedAction(sender: UIStepper) {
        viewModel.intervalProperty.value = Int(sender.value)
    }
    @IBAction func inputEditedAction(sender: UITextField) {
        switch sender {
        case tfInterval: viewModel.intervalProperty.value = sender.text.flatMap {Int($0)}
        case tfUrl: viewModel.urlProperty.value = sender.text
        default: break
        }
        setView(sender, valid: true)
    }
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveAction(sender: UIButton) {
        guard viewModel.isValid else {
            highlightErrors()
            return
        }
        if mode == .Edit {
            delegate?.alertEditor(self, didEdit: viewModel)
        } else {
            delegate?.alertEditor(self, didAdd: viewModel)
        }
    }
    @IBAction func cancelAction(sender: AnyObject) {
        delegate?.alertEditorDidCancel(self)
    }
    
    func highlightErrors() {
        [(tfUrl, viewModel?.urlProperty.isValid),
        (tfInterval, viewModel?.intervalProperty.isValid),
        ].forEach {
                setView($0.0, valid: $0.1 ?? true)
        }
    }
    
    func resetErrors() {
        [tfUrl, tfInterval].forEach {
            setView($0, valid: true)
        }
    }
    
    func setView(view : UIView, valid : Bool) {
        view.borderColor = valid ? UIColor.lightGrayColor() : UIColor.redColor()
    }

}

private enum Mode {
    case Add
    case Edit
}
