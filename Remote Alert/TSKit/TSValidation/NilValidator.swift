/// Requires value to be not `nil`.
/// - Parameter Any: Accepts any values.
open class NilValidator : Validator {
    open let failedMessage = "Value can't be empty"
    
    open func validate(_ value: Any?) -> Bool {
        return value != nil
    }
    
    public init() {}
}
