/// Defines how `CompoundValidator` should treat specified set of `Validators`.
enum ValidationConjunction {
    
    /// Valid if all provided validators are valid.
    case All
    
    /// Valid if at least one of provided validators is valid.
    case Any
    
    /// Valid if all provided validators are not valid.
    case None
}

struct CompoundValidator : Validator {
    let conjunction : ValidationConjunction
    let validators : [Validator]
    
    var failedMessage: String {
        return self.validators.map{$0.failedMessage}.joinWithSeparator(", ")
    }
    
    init(validators : [Validator], conjunction : ValidationConjunction = .All) {
        self.conjunction = conjunction
        self.validators = validators
    }
    
    func validate(value: Any?) -> Bool {
        guard self.validators.count > 0 else {
            print("\(self.dynamicType): No validators provided.")
            return true
        }
        let passed = self.validators.filter{$0.validate(value)}
        switch self.conjunction {
        case .All: return self.validators.count == passed.count
        case .Any: return passed.count > 0
        case .None: return passed.count == 0
        }
    }
}

// MARK: .All
func & (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .All)
}

func & (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .All)
}

func & (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 & [v2]
}

func & (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] & v2
}

// MARK: .Any
func | (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .Any)
}

func | (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .Any)
}

func | (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 | [v2]
}

func | (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] | v2
}

// MARK: .None
func ^ (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .None)
}

func ^ (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .None)
}

func ^ (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 ^ [v2]
}

func ^ (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] ^ v2
}

