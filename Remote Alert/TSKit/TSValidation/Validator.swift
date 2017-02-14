// Date: 10/31/2016

/// Defines a validator interface.
protocol Validator {
    
    /// Validates given value.
    /// - Note: Validator must return true for unsupported value types to indicate that they have nothing to do with this value.
    func validate(value : Any?) -> Bool
    
    /// Message describing validator's requirements.
    var failedMessage : String {get}
    
    /// Complementary method to be called by conforming types when received unsupported value types.
    func logUnsupportedType(value : Any?)
}

/// Defines validator which forwards it's validation to specific proxy validator. 
protocol ProxyValidator : Validator {
    var proxyValidator : Validator {get}
}

// MARK: - Defaults

extension Validator {
    func logUnsupportedType(value : Any?) {
        print("\(self.dynamicType): Received value with unsupported type \(value.dynamicType).")
    }
    
    func logEmpty() {
        print("\(self.dynamicType): Received nil.")
    }
}

/// Implements default validation forwarding.
extension ProxyValidator {
    func validate(value: Any?) -> Bool {
        return self.proxyValidator.validate(value)
    }
}