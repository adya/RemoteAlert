struct InvertedValidator : ProxyValidator {
    let proxyValidator: Validator
    var failedMessage: String {
        return "Inverted: \(self.proxyValidator.failedMessage)"
    }
    
    init(validator : Validator) {
        self.proxyValidator = validator
    }
    
    func validate(value: Any?) -> Bool {
        return !self.proxyValidator.validate(value)
    }
}

prefix func !(validator : Validator) -> Validator {
    return InvertedValidator(validator : validator)
}