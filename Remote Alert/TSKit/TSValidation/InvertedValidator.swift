open class InvertedValidator : ProxyValidator {
    public init(validator : Validator) {
        super.init(proxy: validator,
                   message: "Inverted: \(validator.failedMessage)")
    }
    
    open override func validate(_ value: Any?) -> Bool {
        return !super.validate(value)
    }
}

public prefix func !(validator : Validator) -> Validator {
    return InvertedValidator(validator : validator)
}
