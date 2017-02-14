class DictionaryStorageProvider : StorageProvider {
    private var dic = [String : AnyObject]()
    
    subscript(key : String) -> AnyObject? {
        get {
            return dic[key]
        }
        set {
            dic[key] = newValue
        }
    }
    
    func removeAll() {
        dic.removeAll()
    }
    
    var count: Int {
        get {
            return dic.count
        }
    }
    
    var dictionary: [String : AnyObject] {
        return dic
    }
}