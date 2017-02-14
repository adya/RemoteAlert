/// Validates an url.
struct UrlValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern:"((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+")
    let failedMessage = "This is not a valid URL"
}