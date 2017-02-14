struct ClosureValidator<T> : Validator {
    let failedMessage: String
    let closure : (T?) -> Bool
    
    init(message : String, closure : (T?) -> Bool) {
        self.closure = closure
        self.failedMessage = message
    }
    
    func validate(value: Any?) -> Bool {
        guard let supportedValue = value as? T else {
            self.logUnsupportedType(value)
            return true
        }
        return self.closure(supportedValue)
    }
}