import Foundation

// MARK: - Grouping
public extension SequenceType {
    
    /// Groups any sequence by the key specified in the closure and creates a dictionary.
    public func groupBy<G : Hashable>(closure : (Generator.Element) -> G?) -> [G : [Generator.Element]] {
        let results : [G: Array<Generator.Element>] = self.reduce([:]) {
            guard let key = closure($1) else {
                return $0
            }
            var dic = $0
            if var array = dic[key] {
                array.append($1)
                dic[key] = array
            }
            else {
                dic[key] = [$1]
            }
            return dic
        }
        return results
    }
}

// MARK: - Distinct
public extension SequenceType where Generator.Element: Hashable {
    public var distinct : [Generator.Element] {
        return Array(Set(self))
    }
}

public extension SequenceType where Generator.Element : Equatable {
    public var distinct : [Generator.Element] {
        return self.reduce([]){uniqueElements, element in
            uniqueElements.contains(element)
                ? uniqueElements
                : uniqueElements + [element]
        }
    }
}

public extension SequenceType {
    public func distinct<T : Equatable>(@noescape transform: (Self.Generator.Element) -> T?) -> [Generator.Element] {
        return self.reduce(([], [])){ (unique : ([T], [Generator.Element]), element : Generator.Element) in
            guard let key = transform(element) else {
                return unique
            }
            return unique.0.contains(key)
                ? unique
                : (unique.0 + [key], unique.1 + [element])
            }.1
    }
}

// MARK: Dictionary filtering

public extension Dictionary {
    /// Returns filtered dictionary.
    public func filter(@noescape includeElement: (Generator.Element) throws -> Bool) rethrows -> [Key : Value] {
        var dict = [Key : Value]()
        let res : [Generator.Element] = try self.filter(includeElement)
        res.forEach { dict[$0.0] = $0.1 }
        return dict
    }
}

// MARK: Array's elements value access.
public extension Array where Element : Equatable {
    
    /// Allows to access element in the array by it's value. This can be handy when you need to update value in the array and don't know its index.
    /// - Attetion: Do not use this subscript to directly modify properties of contained objects.
    public subscript (element : Generator.Element) -> Generator.Element? {
        get {
            if let index = self.indexOf(element) {
                return self[index]
            } else {
                return nil
            }
        }
        set {
            if let index = self.indexOf(element) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    self.removeAtIndex(index)   
                }
            }
        }
    }
}

public func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }

// MARK: - Random
/// Adds handy random support.
public extension IntervalType {
    /// Gets random value from the interval.
    public var random : Bound {
        let range = (self.end as! Float) - (self.start as! Float)
        let randomValue = (Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * range + (self.start as! Float)
        return randomValue as! Bound
    }
}

public extension CollectionType {
    /// Gets random value from the range.
    public var random : Self._Element {
        if let startIndex = self.startIndex as? Int {
            let start = UInt32(startIndex)
            let end = UInt32(self.endIndex as! Int)
            return self[Int(arc4random_uniform(end - start) + start) as! Self.Index]
        }
        var generator = self.generate()
        var count = arc4random_uniform(UInt32(self.count as! Int))
        while count > 0 {
            let _ = generator.next()
            count = count - 1
        }
        return generator.next() as! Self._Element
    }
}

public extension Array {
    /// Returns an array containing this sequence shuffled
    public var shuffled : Array {
        var shuffled = self
        self.indices.dropLast().forEach { a in
            guard case let b = Int(arc4random_uniform(UInt32(self.count - a))) + a where b != a else { return }
            shuffled[a] = self[b]
        }
        return self
    }
    
    /// Gets random `n` elements from the array.
    public func random(n: Int) -> Array { return Array(self.shuffled.prefix(n)) }

}

// MARK: - Strings
public extension String {
    
    public var range : Range<String.Index> {
        return self.startIndex..<self.endIndex
    }
    
    public var nsrange : NSRange {
        return NSMakeRange(0, self.characters.count)
    }
}