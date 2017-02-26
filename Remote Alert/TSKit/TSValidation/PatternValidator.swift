/// - Requires: TSRegex.swift

open class PatternValidator : Validator {
    let pattern : String
    open let failedMessage : String
    
    public init(pattern : String) {
        self.pattern = pattern
        self.failedMessage = "Does not match '\(self.pattern)' pattern"
    }
    
    open func validate(_ value: Any?) -> Bool {
        guard let stringValue = value as? Textual else {
            self.logUnsupportedType(value)
            return true
        }
        return stringValue.text =~ self.pattern
    }
}
