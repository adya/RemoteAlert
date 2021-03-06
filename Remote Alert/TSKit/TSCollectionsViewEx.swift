/// TSTOOLS: Description... date 09/02/16
/// Modified : 09/23/16

import UIKit

protocol TSReusableView  : TSIdentifiable, TSConfigurable, TSStylable {}

extension TSReusableView {
    func style(with styleSource: Any) { /* Do nothing, as styling is optional. */ }
}


protocol TSTableViewElement : TSReusableView {
    static var height : CGFloat {get}
    var dynamicHeight : CGFloat {get}
}

protocol TSCollectionViewElement : TSReusableView {
    static var size : CGSize {get}
    var dynamicSize : CGSize {get}
}

extension TSTableViewElement {
    static var height: CGFloat {
        return 44
    }
    
    var dynamicHeight : CGFloat {
        return 44
    }
}

extension TSCollectionViewElement {
    var dynamicSize : CGSize {
        return CGSize(width: 0, height: 0)
    }
}

extension UITableView {
    
    func dequeueReusableCellOfType<T where T : UITableViewCell, T : TSTableViewElement> (type : T.Type) -> T {
        let id = type.identifier
        if let cell = self.dequeueReusableCellWithIdentifier(id) {
            return cell as! T
        }
        else {
            let nib = UINib(nibName: id, bundle: NSBundle.mainBundle())
            self.registerNib(nib, forCellReuseIdentifier: id)
            return self.dequeueReusableCellOfType(type)
        }
    }
    
    @available(iOS 6.0, *)
    func dequeueReusableCellOfType<T where T : UITableViewCell, T : TSTableViewElement> (type : T.Type, forIndexPath indexPath : NSIndexPath) -> T {
        let id = type.identifier
        
        let cell = self.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath)
        if let tsCell = cell as? T {
            return tsCell
        } else {
            let nib = UINib(nibName: id, bundle: NSBundle.mainBundle())
            self.registerNib(nib, forCellReuseIdentifier: id)
            return self.dequeueReusableCellOfType(type, forIndexPath: indexPath)
        }
    }
    
    func dequeueReusableViewOfType<T where T : UITableViewHeaderFooterView, T : TSTableViewElement> (type : T.Type) -> T {
        let id = type.identifier
        if let view = self.dequeueReusableHeaderFooterViewWithIdentifier(id) {
            return view as! T
        }
        else {
            let nib = UINib(nibName: id, bundle: NSBundle.mainBundle())
            self.registerNib(nib, forHeaderFooterViewReuseIdentifier: id)
            return self.dequeueReusableViewOfType(type)
        }
    }
}

@available(iOS 6.0, *)
extension UICollectionView {
    func dequeueReusableCellOfType<T where T : UICollectionViewCell, T : TSCollectionViewElement> (type : T.Type, forIndexPath indexPath : NSIndexPath) -> T {
        let id = type.identifier
        let cell = self.dequeueReusableCellWithReuseIdentifier(id, forIndexPath: indexPath)
        if let tsCell = cell as? T {
            return tsCell
        } else {
            let nib = UINib(nibName: id, bundle: NSBundle.mainBundle())
            self.registerNib(nib, forCellWithReuseIdentifier: id)
            return self.dequeueReusableCellOfType(type, forIndexPath: indexPath)
        }
    }
    
    @available(iOS 8.0, *)
    func dequeueReusableHeaderViewOfType<T where T : UICollectionReusableView, T : TSCollectionViewElement> (type : T.Type, forIndexPath indexPath : NSIndexPath) -> T {
        return self.dequeueReusableSupplementaryViewOfType(type, kind: UICollectionElementKindSectionHeader, forIndexPath: indexPath)
    }
    
    @available(iOS 8.0, *)
    func dequeueReusableFooterViewOfType<T where T : UICollectionReusableView, T : TSCollectionViewElement> (type : T.Type, forIndexPath indexPath : NSIndexPath) -> T {
        return self.dequeueReusableSupplementaryViewOfType(type, kind: UICollectionElementKindSectionFooter, forIndexPath: indexPath)
    }
    
    @available(iOS 8.0, *)
    private func dequeueReusableSupplementaryViewOfType<T where T : UICollectionReusableView, T : TSCollectionViewElement> (type : T.Type, kind: String, forIndexPath indexPath : NSIndexPath) -> T {
        let id = type.identifier
        
        let cell = self.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: id, forIndexPath: indexPath)
        return cell as! T
        //        }
        //        catch {
        //            let nib = UINib(nibName: id, bundle: NSBundle.mainBundle())
        //            self.registerNib(nib, forSupplementaryViewOfKind:kind, withReuseIdentifier: id)
        //            return self.dequeueReusableHeaderViewOfType(type, forIndexPath:indexPath)
        //        }
    }
}