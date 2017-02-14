/// - Requires: TSRegex.swift

struct PatternValidator : Validator {
    let pattern : String
    let failedMessage : String
    
    init(pattern : String) {
        self.pattern = pattern
        self.failedMessage = "Does not match '\(self.pattern)' pattern"
    }
    
    func validate(value: Any?) -> Bool {
        guard let stringValue = value as? Textual else {
            self.logUnsupportedType(value)
            return true
        }
        return stringValue.text =~ self.pattern
    }
}