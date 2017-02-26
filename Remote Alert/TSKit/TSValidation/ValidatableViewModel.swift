/**
 Defines ViewModel which will have ValidatableProperties.
 ### Common usage example:
 ```
    protocol SomeViewModel : ValidatableViewModel {
        var property : ValidatableProperty<String> {get set}
        var nestedViewModel : SomeValidatableViewModel {get}

        /// other properties...
 
        var validatables: [Validatable] {
            return [self.property, self.nestedViewModel] // Any other properties which you want to be valid.
        }
    }
 ```
 */
public protocol ValidatableViewModel : Validatable {
    
    /// Returns true if all `validatables` have passed validation.
    var isValid : Bool {get}
    
    /// Returns an array of validatable properties of `self` that must be validated to determine ViewModel as valid.
    var validatables : [Validatable] {get}
}

/// Defines default ViewModel validation algorithm via `validatables` property.
public extension ValidatableViewModel {
    public var isValid: Bool {
        let failedValidatables = self.validatables.filter{ !$0.isValid }
        if !failedValidatables.isEmpty {
            let errors = failedValidatables.flatMap {$0.validationErrors}
            let prettyErrors = errors.joined(separator: ",\n")
            print("\(type(of: self)): Failed with errors: \(prettyErrors).")
        }
        return failedValidatables.isEmpty
    }
    
    public var validationErrors: [String] {
        return self.validatables.filter{!$0.isValid}.flatMap{$0.validationErrors}
    }
}

/// Represents validatable entity.
public protocol Validatable {
    var isValid : Bool {get}
    var validationErrors : [String] {get}
}
