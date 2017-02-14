import Foundation

/**
 *  Author:     AdYa
 *  Version:    3.1b
 *  iOS:        2.0+
 *  Date:       08/21/2016
 *  Status:     Completed
 *
 *  Description:
 *
 *  TSStorage protocol represents a common way to save values in storages of any kind.
 */
public protocol TSStorage : class {
    
    /** Convinient way to access stored values. 
     *  @param key Key associated with an object.
     */
    subscript(key : String) -> AnyObject? {get set}
    
    /** Number of stored objects.
     *  @return Returns number of stored objects.
     */
    var count : Int {get}
    
    /** Saves object in storage and associates it with given key.
     *  @param object Object to be saved.
     *  @param key Key associated with an object.
     */
    func saveObject(object: AnyObject, forKey key: String)
   
    /** Loads object associated with given key.
     *  @param key Key associated with an object.
     *  @return Returns object if any or nil.
     */
    func loadObjectForKey(key: String) -> AnyObject?
    
    /** Loads object associated with given key and if exists - removes it from storage.
     *  @param key Key associated with an object.
     *  @return Returns object if any or nil.
     */
    func popObjectForKey(key: String) -> AnyObject?
    
    /** Removes object associated with specified key.
     *  @param key Key associated with an object.
     */
    func removeObjectForKey(key: String)
    
    /** Removes all objects from the storage. */
    func removeAllObjects()
    
    /** Checks whether the object, associated with given key, exists in storage.
     *  @param key Key associated with an object.
     *  @return Returns YES if object exists.
     */
    func hasObjectForKey(key: String) -> Bool
    
    var dictionary : [String : AnyObject] {get}
}

public extension TSStorage {
    public subscript(key : String) -> AnyObject? {
        get {
            return loadObjectForKey(key)
        }
        set {
            if let value = newValue {
                saveObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}

struct Storage {
    static let local : TSStorage = TSStorageProvider.localStorage
    static let temp : TSStorage = TSStorageProvider.tempStorage
    static let remote : TSStorage = TSStorageProvider.remoteStorage
}

private class TSStorageProvider {
    static private var tempStorage : TSStorage = BaseStorage(storage:DictionaryStorageProvider())
    static private var localStorage : TSStorage = BaseStorage(storage: UserDefaultsStorageProvider())
    static private var remoteStorage : TSStorage = BaseStorage(storage: UbiquitousStorageProvider())
}

private class BaseStorage : TSStorage {
    private let storage : StorageProvider

    var count : Int {
        get {
            return storage.count
        }
    }
    
    var dictionary: [String : AnyObject] {
        return storage.dictionary
    }
    
    init(storage: StorageProvider){
        self.storage = storage
    }
    
    func saveObject(object: AnyObject, forKey key: String) {
        storage[key] = object
    }
    
    func loadObjectForKey(key: String) -> AnyObject? {
        return storage[key]
    }
    
    func popObjectForKey(key: String) -> AnyObject? {
        if let obj = self.loadObjectForKey(key) {
            self.removeObjectForKey(key)
            return obj
        }
        return nil
    }
    
    func removeObjectForKey(key: String) {
        storage[key] = nil
    }
    
    func removeAllObjects() {
        storage.removeAll()
    }
    
    func hasObjectForKey(key: String) -> Bool {
        return (self.loadObjectForKey(key) != nil)
    }
    
}