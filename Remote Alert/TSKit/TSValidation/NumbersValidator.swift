/// Validates number only.
open class NumbersValidator : ProxyValidator {
    public init() {
        super.init(proxy: PatternValidator(pattern: "\\d+"),
                   message: "Only numbers are allowed")
    }
}
