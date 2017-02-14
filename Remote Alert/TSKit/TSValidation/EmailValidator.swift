/// Validates an email.
struct EmailValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "([A-Z0-9a-z._%+-]+)@(?:([A-Za-z0-9-]+)\\.)+([A-Za-z]{2,6})")
    let failedMessage = "This is not a valid email"
}