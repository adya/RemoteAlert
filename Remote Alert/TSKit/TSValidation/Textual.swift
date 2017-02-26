/// Defines a type that can be represented as String.
public protocol Textual : Countable {
    var text : String {get}
}

extension String : Textual {
    public var text: String {
        return self
    }
}

public extension Textual {
    public var count: Int {
        return self.text.count
    }
}