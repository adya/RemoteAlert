/// Defines validator which forwards it's validation to specific proxy validator.
open class ProxyValidator : Validator {
    fileprivate let proxyValidator : Validator
    open let failedMessage : String
    
    init(proxy : Validator, message : String) {
        proxyValidator = proxy
        failedMessage = message
    }
    
    convenience init(proxy : Validator) {
        self.init(proxy: proxy, message: proxy.failedMessage)
    }
    
    open func validate(_ value : Any?) -> Bool {
        return proxyValidator.validate(value)
    }
}
