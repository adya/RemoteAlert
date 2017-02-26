import UIKit

@IBDesignable
class TSViewEx : UIView {}

extension UIView {
    
    @IBInspectable var borderWidth : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
        
        set {
            self.layer.borderColor = newValue?.cgColor
        }
        
    }
    
    @IBInspectable var circle : Bool {
        get {
            return cornerRadius == self.frame.width/2
        }
        set {
            let minDimension = min(self.frame.width, self.frame.height)
            cornerRadius = (newValue ? minDimension/2 : 0)
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.masksToBounds = newValue > 0
            self.layer.cornerRadius = newValue
        }
    }
}
