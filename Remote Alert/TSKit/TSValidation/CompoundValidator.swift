open class CompoundValidator : Validator {
    fileprivate let conjunction : ValidationConjunction
    fileprivate let validators : [Validator]
    
    open var failedMessage: String {
        return self.validators.map{$0.failedMessage}.joined(separator: ", ")
    }
    
    public init(validators : [Validator], conjunction : ValidationConjunction = .all) {
        self.conjunction = conjunction
        self.validators = validators
    }
    
    open func validate(_ value: Any?) -> Bool {
        guard self.validators.count > 0 else {
            print("\(type(of: self)): No validators provided.")
            return true
        }
        let passed = self.validators.filter{$0.validate(value)}
        switch self.conjunction {
        case .all: return self.validators.count == passed.count
        case .any: return passed.count > 0
        case .none: return passed.count == 0
        }
    }
}

/// Defines how `CompoundValidator` should treat specified set of `Validators`.
public enum ValidationConjunction {
    
    /// Valid if all provided validators are valid.
    case all
    
    /// Valid if at least one of provided validators is valid.
    case any
    
    /// Valid if all provided validators are not valid.
    case none
}

// MARK: .All
public func & (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .all)
}

public func & (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .all)
}

public func & (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 & [v2]
}

public func & (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] & v2
}

// MARK: .Any
public func | (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .any)
}

public func | (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .any)
}

public func | (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 | [v2]
}

public func | (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] | v2
}

// MARK: .None
public func ^ (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .none)
}

public func ^ (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .none)
}

public func ^ (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 ^ [v2]
}

public func ^ (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] ^ v2
}

