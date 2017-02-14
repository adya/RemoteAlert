private let defaultLengthName = "Length"

/// - Parameter String: Validates `String`'s length.
/// - Parameter Array: Validates `Array`'s size.
/// - Parameter Set: Validates `Set`'s size.
/// - Parameter Dictionary: Validates `Dictionary`'s size.
/// - Parameter Countable: Validates count of any `Countable`.
struct LengthValidator : ProxyValidator {
    let proxyValidator: Validator
    var failedMessage: String {
        return self.proxyValidator.failedMessage
    }
    
    private init(validator : Validator) {
        self.proxyValidator = validator
    }
    
    init(minLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minBound: minLength, valueName: defaultLengthName))
    }
    
    init(minLength : Int) {
        self.init(validator: ValueValidator(minValue: minLength, valueName: defaultLengthName))
    }
    
    init(maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(maxBound: maxLength, valueName: defaultLengthName))
    }
    
    init(maxLength : Int) {
        self.init(validator: ValueValidator(maxValue: maxLength, valueName: defaultLengthName))
    }
    
    init(minLength : ValueBound<Int>, maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minBound: minLength, maxBound: maxLength, valueName: defaultLengthName))
    }
    
    init(minLength : Int, maxLength : Int) {
        self.init(validator: ValueValidator(minValue: minLength, maxValue: maxLength, valueName: defaultLengthName))
    }
    
    init(minLength : ValueBound<Int>, maxLength : Int) {
        self.init(validator: ValueValidator(minBound: minLength, maxValue: maxLength, valueName: defaultLengthName))
    }
    
    init(minLength : Int, maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minValue: minLength, maxBound: maxLength, valueName: defaultLengthName))
    }
    
    init(exactLength : Int) {
        self.init(validator: ValueValidator(exactValue: exactLength, valueName: defaultLengthName))
    }
    
    func validate(value: Any?) -> Bool {
        guard let countable = value as? Countable else {
            self.logUnsupportedType(value)
            return true
        }
        return self.proxyValidator.validate(countable.count)
    }
}

