/// Validates non empty strings or collections.
/// - Parameter String: Validates non empty string.
/// - Parameter Array: Validates non empty array.
/// - Parameter Set: Validates non empty set.
/// - Parameter Dictionary: Validates non empty dictionary.
/// - Parameter Countable: Any type which conformes to Countable protocol.
struct NonEmptyValidator : Validator {
    let failedMessage = "Filed must not be empty"
    func validate(value: Any?) -> Bool {
        guard let countable = value as? Countable else {
            self.logUnsupportedType(value)
            return true
        }
        return countable.count > 0
    }
}