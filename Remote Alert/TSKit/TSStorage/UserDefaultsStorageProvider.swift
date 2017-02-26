/// `NSUserDefaults` storage data source.
class UserDefaultsStorageProvider : StorageProvider {
    fileprivate var storage = UserDefaults.standard
    
    subscript(key : String) -> Any? {
        set {
            if newValue == nil {
                storage.set(nil, forKey: key)
            } else if let newValue = newValue as? AnyObject {
                storage.set(newValue, forKey: key)
            } else {
                print("\(type(of: self)): Value can't be stored.")
            }
        }
        get {
            return storage.object(forKey: key)
        }
    }
    
    func removeAll() {
        if let id = Bundle.main.bundleIdentifier {
            storage.removePersistentDomain(forName: id)
        }
    }
    
    var count: Int {
        get {
            return storage.dictionaryRepresentation().count
        }
    }
    
    var dictionary: [String : Any]{
        return storage.dictionaryRepresentation()
    }
    deinit {
        storage.synchronize()
    }
}
