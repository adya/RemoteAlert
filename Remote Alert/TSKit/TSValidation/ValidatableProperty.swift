/// Represents property wrapper with a validation mechanism.
/// - Since: 10/31/2016
/// - Date: 12/21/2016
/// - Version: 1.3
public protocol AnyValidatableProperty : Validatable {
    /// Validators attached to this property.
    var validators : [Validator] {get}
    
    /// Any validation errors occured during last value change.
    var validationErrors : [String] {get}
    
    /// Flag indicating whether this property has passed all validations or not.
    var isValid : Bool {get}
}

/// Represents property wrapper with validation mechanism
public struct ValidatableProperty<T : Any> : AnyValidatableProperty {
    
    /// Stored value.
    public var value : T? {
        didSet {
            self.validate()
        }
    }
    
    /// Validators attached to this property.
    public let validators : [Validator]
    
    /// Any validation errors occured during last value change.
    public fileprivate(set) var validationErrors : [String] = []
    
    /// Flag indicating whether this property has passed all validations or not.
    public var isValid : Bool {
        return self.validationErrors.isEmpty
    }
    
    public init(value : T?, validators : [Validator]) {
        self.validators = validators
        self.value = value
        self.validate()
    }
    
    /// Performs validation and updates errors if any.
    fileprivate mutating func validate() -> Bool {
        self.validationErrors = self.validators.filter{ !$0.validate(self.value) }.map{ $0.failedMessage }
        return self.isValid
    }
}
