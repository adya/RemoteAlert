open class ClosureValidator<T> : Validator {
    open let failedMessage: String
    open let closure : (T?) -> Bool
    
    public init(message : String, closure : @escaping (T?) -> Bool) {
        self.closure = closure
        self.failedMessage = message
    }
    
    open func validate(_ value: Any?) -> Bool {
        guard let supportedValue = value as? T else {
            self.logUnsupportedType(value)
            return true
        }
        return self.closure(supportedValue)
    }
}
