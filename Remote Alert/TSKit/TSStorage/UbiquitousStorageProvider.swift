class UbiquitousStorageProvider : StorageProvider {
    private var storage = NSUbiquitousKeyValueStore.defaultStore()
    
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
        let keys = dictionary.keys
        for key in keys {
            storage.removeObjectForKey(key)
        }
        storage.synchronize()
    }
    
    
    var count: Int {
        get {
            return storage.dictionaryRepresentation.count
        }
    }
    
    var dictionary: [String : AnyObject]{
        return storage.dictionaryRepresentation
    }
    
    deinit{
        storage.synchronize()
    }
}