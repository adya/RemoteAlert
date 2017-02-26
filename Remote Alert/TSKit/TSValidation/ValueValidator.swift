/// Defines comparison bound for the value.
public enum ValueBound <T : Comparable> {
    
    /// Not include value in valid range.
    case exclusive(T)
    
    /// Include value in valid range.
    case inclusive(T)
}

private let defaultValueName = "Value"

/// - Parameter Comparable: Validates any `Comparable` values.
public struct ValueValidator<ValueType : Comparable> : Validator {
    
    let minBound : ValueBound<ValueType>?
    let maxBound : ValueBound<ValueType>?
    
    public let failedMessage : String
    
    fileprivate init(minBound : ValueBound<ValueType>?,
                 maxBound : ValueBound<ValueType>?,
                 message : String) {
        self.minBound = minBound
        self.maxBound = maxBound
        self.failedMessage = message
    }
    
    public init(minBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let bound : String
        if case .exclusive = minBound { bound = "not less" }
        else { bound = "greater" }
        self.init(minBound: minBound,
                  maxBound: nil,
                  message: "\(valueName.capitalized) must be \(bound) than \(minBound)")
    }
    

    
    public init(maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let bound : String
        if case .exclusive = maxBound { bound = "not greater" }
        else { bound = "less" }
        self.init(minBound: nil,
                  maxBound: maxBound,
                  message: "\(valueName.capitalized) must be \(bound) than \(maxBound)")
    }
    
    
    public init(minBound : ValueBound<ValueType>,
         maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        let maxBoundString : String
        if case .exclusive = maxBound { maxBoundString = " exclusive" }
        else { maxBoundString = "" }
        let minBoundString : String
        if case .exclusive = minBound { minBoundString = " exclusive" }
        else { minBoundString = "" }
        self.init(minBound: min(minBound, maxBound),
                  maxBound: max(minBound, maxBound),
                  message: "\(valueName.capitalized) must be between \(minBound)\(minBoundString) and \(maxBound)\(maxBoundString)")
    }
    
    public init(exactValue : ValueType,
         valueName : String = defaultValueName) {
        self.init(minBound: .inclusive(exactValue), maxBound: .inclusive(exactValue), message: "\(valueName.capitalized) must be equal to \(exactValue)")
    }
    
    public init(maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(maxBound: .inclusive(maxValue), valueName: valueName)
    }
    
    public init(minValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: .inclusive(minValue), valueName: valueName)
    }
    
    public init(minValue : ValueType,
         maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: .inclusive(minValue), maxBound: .inclusive(maxValue), valueName: valueName)
    }
    
    public init(minBound : ValueBound<ValueType>,
         maxValue : ValueType,
         valueName: String = defaultValueName) {
        self.init(minBound: minBound, maxBound: .inclusive(maxValue), valueName: valueName)
    }
    
    public init(minValue : ValueType,
         maxBound : ValueBound<ValueType>,
         valueName: String = defaultValueName) {
        self.init(minBound: .inclusive(minValue), maxBound: maxBound, valueName: valueName)
    }
    
    
    
    public func validate(_ value : Any?) -> Bool {
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
            case .exclusive(let min): return min < valueT
            case .inclusive(let min): return min <= valueT
            }
        } ?? true
        
        let inMaxBound = self.maxBound.flatMap{
            switch $0 {
            case .exclusive(let max): return valueT < max
            case .inclusive(let max): return valueT <= max
            }
            } ?? true
        return inMinBound && inMaxBound
    }
}

private func min<T : Comparable>(_ x : ValueBound<T>, _ y : ValueBound<T>) -> ValueBound<T> {
    if case let .exclusive(xValue) = x, case let .exclusive(yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case let .exclusive(xValue) = x, case let .inclusive(yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case let .inclusive(xValue) = x, case let .exclusive(yValue) = y {
        return xValue < yValue ? x : y
    }
    else if case let .inclusive(xValue) = x, case let .inclusive(yValue) = y {
        return xValue < yValue ? x : y
    } else {
        return x
    }
}

private func max<T : Comparable>(_ x : ValueBound<T>, _ y : ValueBound<T>) -> ValueBound<T> {
    if case let .exclusive(xValue) = x, case let .exclusive(yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case let .exclusive(xValue) = x, case let .inclusive(yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case let .inclusive(xValue) = x, case let .exclusive(yValue) = y {
        return xValue > yValue ? x : y
    }
    else if case let .inclusive(xValue) = x, case let .inclusive(yValue) = y {
        return xValue > yValue ? x : y
    } else {
        return x
    }
}
