/// Requires value to be not empty.
/// - Parameter String: Validates non empty `String`.
/// - Parameter Array: Validates non empty `Array`.
/// - Parameter Set: Validates non empty `Set`.
/// - Parameter Dictionary: Validates non empty `Dictionary`.
/// - Parameter Countable: Any type which conformes to `Countable` protocol.
open class NonEmptyValidator : Validator {
    open let failedMessage = "Filed must not be empty"
    open func validate(_ value: Any?) -> Bool {
        guard let countable = value as? Countable else {
            self.logUnsupportedType(value)
            return true
        }
        return countable.count > 0
    }
}
