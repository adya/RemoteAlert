/// Defines comparison bound for the value.
enum ValueBound <T : Comparable> {
    
    /// Not include value in valid range.
    case Exclusive(T)
    
    /// Include value in valid range.
    case Inclusive(T)
}

private let defaultValueName = "Value"

/// - Parameter Comparable: Validates any `Comparable` values.
struct ValueValidator<ValueType : Comparable> : Validator {
    
    let minBound : ValueBound<ValueType>?
    let maxBound : ValueBound<ValueType>?
    
    let failedMessage : String
    
    private init(minBound : ValueBound<ValueType>?,
                 maxBound : ValueBound<ValueType>?,
                 message : String) {
        self.minBound = minBound
        self.maxBound = maxBound
        self.failedMessage = message
    }
    
    init(minBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let bound : String
        if case .Exclusive = minBound { bound = "not less" }
        else { bound = "greater" }
        self.init(minBound: minBound,
                  maxBound: nil,
                  message: "\(valueName.capitalizedString) must be \(bound) than \(minBound)")
    }
    

    
    init(maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let bound : String
        if case .Exclusive = maxBound { bound = "not greater" }
        else { bound = "less" }
        self.init(minBound: nil,
                  maxBound: maxBound,
                  message: "\(valueName.capitalizedString) must be \(bound) than \(maxBound)")
    }
    
    
    init(minBound : ValueBound<ValueType>,
         maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let maxBoundString : String
        if case .Exclusive = maxBound { maxBoundString = " exclusive" }
        else { maxBoundString = "" }
        let minBoundString : String
        if case .Exclusive = minBound { minBoundString = " exclusive" }
        else { minBoundString = "" }
        self.init(minBound: min(minBound, maxBound),
                  maxBound: max(minBound, maxBound),
                  message: "\(valueName.capitalizedString) must be between \(minBound)\(minBoundString) and \(maxBound)\(maxBoundString)")
    }
    
    init(exactValue : ValueType,
         valueName : String = defaultValueName) {
        self.init(minBound: .Inclusive(exactValue), maxBound: .Inclusive(exactValue), message: "\(valueName.capitalizedString) must be equal to \(exactValue)")
    }
    
    init(maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(maxBound: .Inclusive(maxValue), valueName: valueName)
    }
    
    init(minValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: .Inclusive(minValue), valueName: valueName)
    }
    
    init(minValue : ValueType,
         maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: .Inclusive(minValue), maxBound: .Inclusive(maxValue), valueName: valueName)
    }
    
    init(minBound : ValueBound<ValueType>,
         maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: minBound, maxBound: .Inclusive(maxValue), valueName: valueName)
    }
    
    init(minValue : ValueType,
         maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        self.init(minBound: .Inclusive(minValue), maxBound: maxBound, valueName: valueName)
    }
    
    
    
    func validate(value : Any?) -> Bool {
        guard let value = value else {
            self.logEmpty()
            return false
        }
        guard let valueT = value as? ValueType else {
            self.logUnsupportedType(value)
            return true
        }
        let inMinBound = self.minBound.flatMap{
            switch $0 {
            case .Exclusive(let min): return min < valueT
            case .Inclusive(let min): return min <= valueT
            }
        } ?? true
        
        let inMaxBound = self.maxBound.flatMap{
            switch $0 {
            case .Exclusive(let max): return valueT < max
            case .Inclusive(let max): return valueT <= max
            }
            } ?? true
        return inMinBound && inMaxBound
    }
}

func min<T : Comparable>(x : ValueBound<T>, _ y : ValueBound<T>) -> ValueBound<T> {
    if case .Exclusive(let xValue) = x, .Exclusive(let yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case .Exclusive(let xValue) = x, .Inclusive(let yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case .Inclusive(let xValue) = x, .Exclusive(let yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case .Inclusive(let xValue) = x, .Inclusive(let yValue) = y {
        return xValue < yValue ? x : y
    } else {
        return x
    }
}

func max<T : Comparable>(x : ValueBound<T>, _ y : ValueBound<T>) -> ValueBound<T> {
    if case .Exclusive(let xValue) = x, .Exclusive(let yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case .Exclusive(let xValue) = x, .Inclusive(let yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case .Inclusive(let xValue) = x, .Exclusive(let yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case .Inclusive(let xValue) = x, .Inclusive(let yValue) = y {
        return xValue > yValue ? x : y
    } else {
        return x
    }
}