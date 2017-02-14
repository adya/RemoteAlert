struct NilValidator : Validator {
    let failedMessage = "Value can't be empty"
    
    func validate(value: Any?) -> Bool {
        return value != nil
    }
}