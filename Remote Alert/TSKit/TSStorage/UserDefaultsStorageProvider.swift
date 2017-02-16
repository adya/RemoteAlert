/// `NSUserDefaults` storage data source.
class UserDefaultsStorageProvider : StorageProvider {
    private var storage = NSUserDefaults.standardUserDefaults()
    
    subscript(key : String) -> AnyObject? {
        set {
            if newValue == nil {
                storage.setObject(nil, forKey: key)
            } else {
                storage.setObject(newValue, forKey: key)
            }
        }
        get {
            return storage.objectForKey(key)
        }
    }
    
    func removeAll() {
        if let id = NSBundle.mainBundle().bundleIdentifier {
            storage.removePersistentDomainForName(id)
        }
    }
    
    var count: Int {
        get {
            return storage.dictionaryRepresentation().count
        }
    }
    
    var dictionary: [String : AnyObject]{
        return storage.dictionaryRepresentation()
    }
    
    deinit {
        storage.synchronize()
    }
}