/// Validates letters only.
open class LettersValidator : ProxyValidator {
    init() {
        super.init(proxy: PatternValidator(pattern: "[a-zA-Z]+"),
                   message: "Only letters are allowed")
    }
}
