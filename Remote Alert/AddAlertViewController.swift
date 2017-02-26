import UIKit

protocol AlertEditor {
    var delegate : AlertEditorDelegate? {get set}
    func setAlert(_ alert : Alert)
    func reset()
}

protocol AlertEditorDelegate {
    func alertEditor(_ editor : AlertEditor, didEdit alert : AlertViewModel)
    func alertEditor(_ editor : AlertEditor, didAdd alert : AlertViewModel)
    func alertEditorDidCancel(_ editor : AlertEditor)
}

class AddAlertViewController: StandaloneViewController, AlertEditor, UITextFieldDelegate {

    @IBOutlet weak fileprivate var tfUrl: UITextField!
    @IBOutlet weak fileprivate var tfInterval: UITextField!
    @IBOutlet weak fileprivate var sInterval: UIStepper!
    @IBOutlet weak fileprivate var bSave: UIButton!
    
    fileprivate let manager : AlertManager
    fileprivate var mode : Mode = .add
    
    var delegate : AlertEditorDelegate?
    var viewModel : AlertViewModel! {
        didSet {
            if isViewLoaded {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel != nil {
            configure()
        }
        resetErrors()
        bSave.setTitle(mode == .add ? "Add" : "Save", for: UIControlState())
    }
    
    func setAlert(_ alert: Alert) {
        viewModel = EditableAlertViewModel(alert: alert)
        mode = .edit
        if isViewLoaded {
            resetErrors()
        }
    }
    
    func reset() {
        viewModel = NewAlertViewModel()
        if isViewLoaded {
            resetErrors()
        }
        mode = .add
    }
    
    func configure() {
        tfUrl.text = viewModel.urlProperty.value
        tfInterval.text = viewModel.intervalProperty.value.flatMap{"\($0)"}
        let value = viewModel.intervalProperty.value.flatMap{Double($0)} ?? 0
        sInterval.value = value
        sInterval.maximumValue = value + 1
    }
    @IBAction func intervalChangedAction(_ sender: UIStepper) {
        viewModel.intervalProperty.value = Int(sender.value)
    }
    @IBAction func inputEditedAction(_ sender: UITextField) {
        switch sender {
        case tfInterval: viewModel.intervalProperty.value = sender.text.flatMap {Int($0)}
        case tfUrl: viewModel.urlProperty.value = sender.text
        default: break
        }
        setView(sender, valid: true)
    }
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        guard viewModel.isValid else {
            highlightErrors()
            return
        }
        if mode == .edit {
            delegate?.alertEditor(self, didEdit: viewModel)
        } else {
            delegate?.alertEditor(self, didAdd: viewModel)
        }
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
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
    
    func setView(_ view : UIView, valid : Bool) {
        view.borderColor = valid ? UIColor.lightGray : UIColor.red
    }

}

private enum Mode {
    case add
    case edit
}
