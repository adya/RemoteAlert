import UIKit

@IBDesignable
class TSTextField : UITextField {
    
    @IBInspectable var inset : CGFloat = 0
    
    override func textRectForBounds(bounds : CGRect) -> CGRect {
        let defaultBounds = super.textRectForBounds(bounds)
        let inseted = CGRect(x: defaultBounds.minX + self.inset,
                      y: defaultBounds.minY,
                      width: defaultBounds.width - 2 * self.inset,
                      height: defaultBounds.height)
        return inseted
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let defaultBounds = super.editingRectForBounds(bounds)
        let inseted = CGRect(x: defaultBounds.minX + self.inset,
                      y: defaultBounds.minY,
                      width: defaultBounds.width - 2 * self.inset,
                      height: defaultBounds.height)
        return inseted
    }
}