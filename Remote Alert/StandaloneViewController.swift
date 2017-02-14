import UIKit

/// `UIViewController` which can be created with default nib file.
class StandaloneViewController : UIViewController, TSIdentifiable {

    /// Loads itself from default `nib`.
    required init() {
        super.init(nibName: self.dynamicType.identifier, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}