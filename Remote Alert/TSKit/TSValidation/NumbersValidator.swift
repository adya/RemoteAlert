/// Validates number only.
struct NumbersValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "\\d+")
    let failedMessage = "Only numbers are allowed"
}