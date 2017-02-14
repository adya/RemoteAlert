/// Validates letters only.
struct LettersValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "[a-zA-Z]+")
    let failedMessage = "Only letters are allowed"
}