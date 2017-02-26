private let defaultLengthName = "Length"

/// - Parameter String: Validates `String`'s length.
/// - Parameter Array: Validates `Array`'s size.
/// - Parameter Set: Validates `Set`'s size.
/// - Parameter Dictionary: Validates `Dictionary`'s size.
/// - Parameter Countable: Validates count of any `Countable`.
open class LengthValidator : ProxyValidator {
    fileprivate init(validator : Validator) {
        super.init(proxy: validator, message: validator.failedMessage)
    }
    
    public convenience init(minLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minBound: minLength, valueName: defaultLengthName))
    }
    
    public convenience init(minLength : Int) {
        self.init(validator: ValueValidator(minValue: minLength, valueName: defaultLengthName))
    }
    
    public convenience init(maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(maxBound: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(maxLength : Int) {
        self.init(validator: ValueValidator(maxValue: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(minLength : ValueBound<Int>, maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minBound: minLength, maxBound: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(minLength : Int, maxLength : Int) {
        self.init(validator: ValueValidator(minValue: minLength, maxValue: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(minLength : ValueBound<Int>, maxLength : Int) {
        self.init(validator: ValueValidator(minBound: minLength, maxValue: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(minLength : Int, maxLength : ValueBound<Int>) {
        self.init(validator: ValueValidator(minValue: minLength, maxBound: maxLength, valueName: defaultLengthName))
    }
    
    public convenience init(exactLength : Int) {
        self.init(validator: ValueValidator(exactValue: exactLength, valueName: defaultLengthName))
    }
    
    open override func validate(_ value: Any?) -> Bool {
        guard let countable = value as? Countable else {
            self.logUnsupportedType(value)
            return true
        }
        return super.validate(countable.count)
    }
}

