// Date: 10/31/2016

/// Defines a validator interface.
public protocol Validator {
    
    /// Validates given value.
    /// - Note: Validator must return true for unsupported value types to indicate that they have nothing to do with this value.
    func validate(_ value : Any?) -> Bool
    
    /// Message describing validator's requirements.
    var failedMessage : String {get}
    
    /// Complementary method to be called by conforming types when received unsupported value types.
    func logUnsupportedType(_ value : Any?)
}

// MARK: - Defaults

public extension Validator {
    public func logUnsupportedType(_ value : Any?) {
        print("\(type(of: self)): Received value with unsupported type \(type(of: value)).")
    }
    
    func logEmpty() {
        print("\(type(of: self)): Received nil.")
    }
}
