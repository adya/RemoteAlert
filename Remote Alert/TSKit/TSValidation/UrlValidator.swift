/// Validates an url.
open class UrlValidator : ProxyValidator {
    public init(){
        super.init(proxy: PatternValidator(pattern: "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"),
                   message: "This is not a valid URL")
    }
}
