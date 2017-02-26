/// Validates an email.
open class EmailValidator : ProxyValidator {
    public init() {
        super.init(proxy: PatternValidator(pattern: "([A-Z0-9a-z._%+-]+)@(?:([A-Za-z0-9-]+)\\.)+([A-Za-z]{2,6})"),
                   message: "This is not a valid email")
    }
}
